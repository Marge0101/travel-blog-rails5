class ToppagesController < ApplicationController
  def index
    if logged_in?
      @user = current_user
      @micropost = current_user.microposts.build  # form_for 用
       #タイムライン追加前：
      #@microposts = current_user.microposts.order('created_at DESC').page(params[:page])
      #タイムライン追加後：
      @microposts = current_user.feed_microposts.order('created_at DESC').page(params[:page])

    end
  end
end