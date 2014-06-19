class UserFriendshipsController < ApplicationController
  def create
    @friendship = current_user.user_friendships.build(:friend_id => params[:friend_id])
    if @friendship.save
        flash[:notice] = "You have sent a friend request."
        redirect_to users_path 
    else
        flash[:error] = "Something went wrong."
        redirect_to users_path
    end
  end

  def destroy
    @friendship = current_user.user_friendships.find(params[:id])
    @friendship.destroy
    flash[:notice] = "You have removed a friend."
    redirect_to users_path
  end
end
