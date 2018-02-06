class UsersController < ApplicationController
  before_action :require_user_logged_in, 
  only: [:index, :show,:edit,:update,:followings, :followers,:favorites_microposts]
  before_action :correct_user,  only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  
  def index
    @users =User.all.page(params[:page])
  end

  def show
    @user =User.find(params[:id])
    @microposts= @user.microposts.order('created_at DESC').page(params[:page])
    counts(@user)
  end

  def new
    @user =User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      log_in @user #ユーザー登録中にログイン
      flash[:success] = "Let's share your recomend place!"
      redirect_to @user
    else
      flash.now[:danger] = "Sorry try again!"
      render :new
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Updated !"
     redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  
  
  def followings
    @user = User.find(params[:id])
    @followings = @user.followings.page(params[:page])
    counts(@user)
  end
  
  def followers
    @user = User.find(params[:id])
    @followers = @user.followers.page(params[:page])
    counts(@user)
  end
  
  def favorites_microposts
    @user =User.find(params[:id])
    @favorites = @user.favorites_microposts.page(params[:page])
    counts(@user)
  end
  
  
  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  
  def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
  end
  
  def admin_user
      redirect_to(root_url) unless current_user.admin?
  end
  
end
