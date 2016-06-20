class UsersController < ApplicationController

  def index
    @users = User.all
    render :index
  end 

  def new
    @user = User.new
    render :new
  end

  def create
    user_params = params.require(:user).permit(:first_name, :last_name, :email, :password)
    user = User.new(user_params)
    if user.save
      login(user)
      redirect_to "/users/#{user.id}"
    else
      redirect_to "/sign_in"
    end
  end

  def show
    @user = User.find(params[:id])
    render :show
  end


  private

  def params_validate
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end

end
