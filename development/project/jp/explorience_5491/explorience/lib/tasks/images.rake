namespace :images do
  namespace :move do
    @parent_dir = Rails.root.join("app/assets/images/experiences")
    @file_or_dir_list = Dir::glob("#{@parent_dir}/*")

    desc "Move experience image files to app/assets/images/experiences."
    task no_git: :environment do
      begin
        puts "Move image files for experiences without git commit.".yellow
        targets, movings, errors = move_experience_images(gitmv: false)
        print_result(targets, movings, errors)
        if errors.size == 0
          puts "\nImage file moving was succeed.".green
        else
          puts "\nFailed to move image files.".red
        end
      rescue => ex
        puts ex.inspect.red
        puts "\nFailed to move image files.".red
      end
    end

    desc "Git move experience image files to app/assets/images/experiences."
    task with_git: :environment do
      begin
        puts "Move image files for experiences with git mv is not implemented now.".yellow
        # FIXME: 日本語フォルダ名の影響で、gitが認識してくれないものがある（ex: 黒部ダム）
        # puts "Move image files for experiences with git mv.".yellow
        # targets, movings, errors = move_experience_images(gitmv: true)
        # print_result(targets, movings, errors)
        # if errors.size == 0
        #   puts "\nImage file moving was succeed.".green
        # else
        #   puts "\nFailed to move image files.".red
        # end
      rescue => ex
        puts ex.inspect.red
        puts "\nFailed to move image files.".red
      end
    end

    desc "Rollback experience image files moving with git mv or mv."
    task rollback: :environment do
      begin
        puts "Restore image files for experiences.".yellow
        targets, movings, errors = restore_experience_images
        print_result(targets, movings, errors)
        if errors.size == 0
          puts "\n\nImage file restoring was succeed. Please check 'git status' and do 'git commit'.".green
        else
          puts "\nFailed to move image files.".red
        end
      rescue => ex
        puts ex.inspect.red
        puts "\nFailed to move image files.".red
      end
    end

    def print_result(targets, movings, errors)
      puts "\n#{targets.size} tries, #{movings.size} moved, #{errors.size} failed.".yellow
      errors.each { |error| puts error.red }
    end

    def move_experience_images(gitmv: false)
      dirs = @file_or_dir_list.dup
      dirs.delete_if { |path| FileTest.file?(path) }
      targets = dirs
      movings = []
      errors  = []

      mv_command = "mv #{@parent_dir}/*/* #{@parent_dir}"
      mv_command = "git #{mv_command}" if gitmv

      if system(mv_command)
        movings = dirs
      else
        errors << "\nFailed to move."
      end

      # TODO: 上記方法で失敗した場合
      # @file_or_dir_list.each do |target|
      #   if FileTest.directory?(target)
      #     targets << target
      #     mv_command = "mv #{target}/* #{@parent_dir}"
      #     mv_command = "git #{mv_command}" if gitmv
      #     if system(mv_command)
      #       movings << target
      #       print '.'.green
      #     else
      #       print 'F'.red
      #       errors << "\nFailed to mv #{target}."
      #     end
      #   else
      #     puts "\n#{target} is not directory".yellow
      #   end
      # end
      # 念のため、タスク中ではcommitしない
      #system('git commit -m "experience image files were moved to parents directory"') if gitmv
      return targets, movings, errors
    end

    # FIXME: ファイル名にスペースが入っていると移動できない
    def restore_experience_images
      targets = []
      movings = []
      errors  = []

      files = @file_or_dir_list.dup
      files.delete_if { |path| FileTest.directory?(path) }

      files.each do |filepath|
        dirname = File.basename(filepath).split('.').first
        target_dir = File.join(@parent_dir, dirname)
        if FileTest.exist?(target_dir) && FileTest.directory?(target_dir)
          targets << filepath
          mv_command = "mv #{filepath} #{target_dir}"
          git_mv_command = "git #{mv_command}"
          if system(git_mv_command)
            print '.'.green
            movings << filepath
          else
            puts "\nFailed to git mv to #{target_dir}. Try mv command.".yellow
            if system(mv_command)
              print '.'.green
              movings << filepath
            else
              print 'F'.red
              errors << "\nFailed to mv to #{target_dir}."
            end
          end
        else
          print 'F'.red
          errors << "\n#{target_dir} directory is not exist."
        end
      end
      return targets, movings, errors
    end
  end
end
