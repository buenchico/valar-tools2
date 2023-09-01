class StaticPagesController < ApplicationController
  def home
  end

  def about
  end

  def contact
  end

  def bug
    message = ""
    DiscourseApi::DiscoursePostData.post_bug(message)
  end

  def bug_report
  end
end
