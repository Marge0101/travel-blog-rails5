class SessionsController < ApplicationController
  def new
  end

  def create
    email = params[:session][:email].downcase
    password = params[:session][:password]
    if login(email,password)
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      #remember user
      flash[:success]='ログインに成功しました。'
      redirect_to @user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end
  def destroy
    log_out if logged_in?
    session[:user_id] = nil
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
  
end

private

def login(email,password)
  @user = User.find_by(email: email)
  #email passwordが同じか検証
  if @user && @user.authenticate(password)
    #ログイン成功
    session[:user_id] = @user.id
    return true
    else
    #ログイン失敗
    return false
  end
end