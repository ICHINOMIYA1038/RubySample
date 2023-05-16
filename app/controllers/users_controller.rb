class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy,:following,:followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    @users = User.paginate(page:params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page:params[:page])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
      #更新に成功した場合
    else 
      render 'edit',status: :unprocessable_entity
    end
  end

  def create 
    @user = User.new(user_params)
    if @user.save
      reset_session
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
     #保存の成功をここで扱う。
    else 
      render 'new', status: :unprocessable_entity
      #レスポンスステータスを422に指定。
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow' , status: :unprocessable_entity
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow',status: :unprocessable_entity
  end
  

  private 
    def user_params
      params.require(:user).permit(:name,:email,:password,:password_confirmation)
    end

    # beforeフィルタ

=begin applicationControllerにまとめて記述
    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url, status: :see_other
      end
    end
=end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
end