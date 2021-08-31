class CellphoneTokensController < ApplicationController

  def create
    unless params[:cellphone] =~ User::CELLPHONE_RE
      render json: {status: 'error', message: "Incorrect phone number format"}
      return
    end

    if session[:token_created_at] and
      session[:token_created_at] + 60 > Time.now.to_i
      render json: {status: 'error', message: "try agian"}
      return
    end

    token = RandomCode.generate_cellphone_token
    VerifyToken.upsert params[:cellphone], token
    SendSMS.send params[:cellphone], "#{token} Verification code, registration"
    session[:token_created_at] = Time.now.to_i
    render json: {status: 'ok'}
  end

end
