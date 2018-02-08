module SessionsHelper
  #いる場合、現在のログインユーザーを返す
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  
  #ログインする
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  def current_user?(user)
    user == current_user
  end
  
  def current_user
    #@current_user ||= User.find_by(id: session[:user_id])#いる場合ログインしているユーザーを返す（通常バージョン）
  # 記憶トークンcookieに対応するユーザーを返す（保持バージョン）
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  
  #ユーザーがログインしていればT、していなければF
  def logged_in?
    !!current_user
  end
  
  # 永続的セッションを破棄する
  def forget(user)
    current_user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  
end
