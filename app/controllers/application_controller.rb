class ApplicationController < ActionController::API
  include Api::V1::RescueExceptions
  
  def render_success(data, message: 'Success', status: :ok)
    render json: {
      success: true,
      message: message,
      data: data
    }, status: status
  end

  def render_error(message, status: :bad_request)
    response = {
      success: false,
      message: message
    }

    render json: response, status: status
  end
end
