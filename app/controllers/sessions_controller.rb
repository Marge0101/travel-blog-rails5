class SessionsController < ApplicationController
  def new
  end

  def create
    
    #email = params[:session][:email].downcase
    #password = params[:session][:password]
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        flash[:success]='ログインに成功しました。'
        log_in user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        redirect_to user
      else
          message  = "Account not activated. "
          message += "Check your email for the activation link."
          flash[:warning] = message
          redirect_to root_url
      end
    else
     flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end
    
   #<--通常ログイン向け--> 
    #if login(email,password)
      #remember user
      #flash[:success]='ログインに成功しました。'
      #redirect_to @user
    #<--ここまで通常ログイン向け--> 

  def destroy
    log_out if logged_in?
    #session[:user_id] = nil
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