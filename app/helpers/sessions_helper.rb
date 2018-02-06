module SessionsHelper
  #いる場合、現在のログインユーザーを返す
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  
  #ログインする
  def log_in(user)
    session[:user_id] = user.id
  end
  
  #ユーザーがログインしていればT、していなければF
  def logged_in?
    !!current_user
  end
end
