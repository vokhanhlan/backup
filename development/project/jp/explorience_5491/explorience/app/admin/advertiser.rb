ActiveAdmin.register Advertiser do
  menu priority: 10

  index title: '広告主情報'

  show title: '広告主情報詳細' do |advertiser|
    panel "#{advertiser.name}様 基本情報" do
      attributes_table_for advertiser, :id, :ad_type, :created_at, :updated_at
    end
    advertiser.experiences.each do |experience|
      panel "ID:#{experience.id} #{experience.title} - アフィリエイト情報" do
        # Header informations
        div class: 'header-information' do
          span "Impression: #{experience.affiliations.impression.count}"
          span "Click link: #{experience.affiliations.click_link.count}"
        end
        # CSV download link
        div class: 'header-action' do
          span link_to(
            'Report all to CSV',
            params.merge(action: :download_report, experience_id: experience.id),
            class: 'btn btn--csv-download'
          )
          span link_to(
            'Report impressions to CSV',
            params.merge(action: :download_report, experience_id: experience.id, action_type: 'impression'),
            class: 'btn btn--csv-download'
          )
          span link_to(
            'Report click links to CSV',
            params.merge(action: :download_report, experience_id: experience.id, action_type: 'click_link'),
            class: 'btn btn--csv-download'
          )
        end
        # Affiliations
        # TODO HACK: 下記の同じような処理をまとめられないか
        panel '直近10件のインプレッション' do
          affiliations = experience.affiliations.impression.order(created_at: :desc).limit(10)
          table do
            tr do
              th '種別'
              th 'ユーザーID'
              th '取得日'
            end
            affiliations.each do |affiliation|
              tr do
                td affiliation.action_type
                td affiliation.user_id ? affiliation.user_id : '未ログイン'
                td affiliation.created_at
              end
            end
          end
        end
        panel '直近10件のリンククリック' do
          affiliations = experience.affiliations.click_link.order(created_at: :desc).limit(10)
          table do
            tr do
              th '種別'
              th 'ユーザーID'
              th '取得日'
            end
            affiliations.each do |affiliation|
              tr do
                td affiliation.action_type
                td affiliation.user_id ? affiliation.user_id : '未ログイン'
                td affiliation.created_at
              end
            end
          end
        end
      end
    end
  end

  # CSV export for each Experiences
  collection_action :download_report, method: :get do
    experience = Experience.find(params[:experience_id])
    csv = CSV.generate(encoding: 'SJIS') do |csv|
      csv << ['ID','Type','user ID','Date']
      affiliations = experience.affiliations
      affiliations = affiliations.__send__(params[:action_type]) if params[:action_type]
      affiliations.order(created_at: :desc).each do |affiliation|
        csv << [ affiliation.id,
                 affiliation.action_type,
                 (affiliation.user_id)? affiliation.user_id : 'not logged in',
                 affiliation.created_at ]
      end
    end
    send_data(
      csv.encode('Shift_JIS'),
      type: 'text/csv; charset=shift_jis; header=present',
      disposition: "attachment; filename=affiliations_report_experience-#{experience.id}#{params[:action_type]}.csv"
    )
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :ad_type, as: :select, collection: Advertiser.ad_types.keys
    end
    f.actions
  end

  permit_params :name, :ad_type
end
