module TopHelper
  # mypage/userpage ユーザー情報内のコンテキスト毎ボタンの非選択状態クラス生成
  def add_context_btn_class(target_context, selected_btns)
    (selected_btns == (target_context.to_s))? "" : "btn_unchecked_color"
  end

  def user_sns_link(provider,user_name)
    case provider.sns_type
    when 'twitter'
      "https://twitter.com/#{user_name}"
    when 'facebook'
      "https://www.facebook.com/#{provider.sns_id}"
    when 'google'
      "https://plus.google.com/#{provider.sns_id}"
    else
      'unknown'
    end
  end

  def link_to_context_filter(context_filter, status)
    context_filter == status ? remove_tag_path(context_filter: status.to_sym) : tag_filter_path(context_filter: status.to_sym, to: root_path)
  end
end
