class Admin::BaseController < ActionController::Base

  layout 'admin/layouts/admin'

  before_action :auth_admin

  private
  def auth_admin
    unless logged_in? and current_user.is_admin?
      flash[:notice] = "Please log in as an administrator"
      redirect_to new_session_path
    end
  end
end
