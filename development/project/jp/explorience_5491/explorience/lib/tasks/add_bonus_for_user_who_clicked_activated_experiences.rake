namespace :user do
  namespace :score do
    namespace :add_bonus do
      desc 'Add bonus for user who clicked activated experiences.'
      task exp_activation: :environment do
        log_file_path = 'log/rake_add_activated_exp_bonus.log'
        @logger = Logger.new(log_file_path)
        add_bonus_log("Add activated experience bonus on #{Time.zone.now}", color: 'green', no_indent: true)
        add_bonus_to_clicked_users(activated_experiences)
        add_bonus_log("Adding activated experience bonus was completed on #{Time.zone.now}\n", color: 'green', no_indent: true)
      end

      # TODO HACK: 他のrakeタスクでも同様の処理を実装しているため、可能であれば共通化する
      # Add bonus log
      # Options:
      #   color         : Specify to std out message color
      #   indent_depth  : Deepness of indent [default 0]
      #   no_indent     : Message output with white-space    (for StdOut)
      #   no_return_code: Message output with no return code (for StdOut)
      def add_bonus_log(str, opt={})
        indent_depth = opt[:no_indent] ? 0 : opt[:indent_depth] || 1
        @logger.info str
        print('  ' * indent_depth) if indent_depth > 0
        opt[:color].present? ? print("#{str}".__send__(opt[:color].to_sym)) : print("#{str}")
        puts "\n" unless opt[:no_return_code]
      end

      # 規定日数前から実行時までに変更および画像追加された体験について、
      # scoreの高い順に規定割合分抽出
      def activated_experiences
        add_bonus_log('Search modified experiences...', color: 'yellow', no_indent: true)

        # Create condition
        from = Constants.user_score.reference_value.activated_exp_by_modifying.period.days.ago
        to   = Time.zone.now
        condition = Experience.arel_table[:updated_at].in(from..to).or(Photo.arel_table[:updated_at].in(from..to))

        # Generate realtion
        all_exps = Experience.joins(:photos).where(condition)

        # Get experiences
        rate = Constants.user_score.reference_value.activated_exp_by_modifying.percentage
        num  = (all_exps.count * rate / 100.0).ceil
        exps = all_exps.evaluation_order.limit(num)

        add_bonus_log('Detect modified experiences.', color: 'green', no_indent: true) if exps.present?
        return exps
      end

      # 対象の体験をクリックしたユーザーに対してスコア加算と履歴生成
      def add_bonus_to_clicked_users(experiences)
        if experiences.blank?
          add_bonus_log('There is no experiences which match the condition. Exit process.', color: 'red', no_indent: true)
          return
        end
        add_bonus_log('Update score to users...', color: 'yellow', no_indent: true)
        users = []
        score_logs = []
        ActiveRecord::Base.transaction do
          experiences.each do |exp|
            add_bonus_log("Experience(ID:#{exp.id}): #{exp.title_ja}", color: 'yellow')
            next if exp.clicking_users.blank?
            add_bonus_log('Awarded users are:', indent_depth: 2)
            exp.clicking_users.where(clickings: { deleted: false }).uniq.each do |user|
              user.score += Constants.user_score.bonus_points.activated_exp_by_modifying
              score_log = ScoreLog.new(user_id: user.id, scored_type: :activated_exp_by_modifying)
              users << user
              score_logs << score_log
              add_bonus_log("ID: #{user.id}, name: #{user.name}", indent_depth: 3)
            end
            add_bonus_log('Update score to awarded users...', color: 'yellow', indent_depth: 2, no_return_code: true)
            User.import users.to_a, on_duplicate_key_update: [:score], validate: false if users.present?
            # FIXME: enumカラムを持つtableへのbulk insertに問題あり。insert時にscored_typeが0として登録されてしまう。
            #   cf. https://github.com/zdennis/activerecord-import/issues/139
            #   cf. https://github.com/zdennis/activerecord-import/pull/173/files
            #   暫定策として、ScoreLogについてはbulk updateせず、1つずつinsertさせる。
            #ScoreLog.import score_logs if score_logs.present?
            score_logs.each { |score_log| score_log.save! }
            add_bonus_log('done', color: 'green', no_indent: true)
            users = []
            score_logs = []
          end
        end
        add_bonus_log('All score updating was done.', color: 'green', no_indent: true)
      end
    end
  end
end
