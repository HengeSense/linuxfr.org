module StatisticsHelper

  def link_to_content_with_score(content, score)
    content_tag(:span, score.to_i, :class => "score") +
      link_to(content.title, url_for_content(content)) +
      "&nbsp;&middot; ".html_safe +
      link_to(content.user.name, user_path(content.user))
  end

  def link_to_user_with_score(user, score)
    content_tag(:span, score.to_i, :class => "score") +
      link_to(user.name, user)
  end

end
