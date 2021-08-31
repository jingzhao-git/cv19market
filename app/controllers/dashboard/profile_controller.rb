class Dashboard::ProfileController < Dashboard::BaseController

  def password
  end

  def update_password
    if current_user.valid_password?(params[:old_password])
      current_user.password_confirmation = params[:password_confirmation]

      if current_user.change_password!(params[:password])
        flash[:notice] = "password updated"
        redirect_to dashboard_password_path
      else
        render action: :password
      end
    else
      current_user.errors.add :old_password, "wrong old password"
      render action: :password
    end
  end
end
