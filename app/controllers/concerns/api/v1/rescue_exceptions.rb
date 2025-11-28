module Api
  module V1
    module RescueExceptions
      extend ActiveSupport::Concern

      included do
        rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
        rescue_from ActiveRecord::RecordNotFound, with: :not_found
        rescue_from Api::Errors::InvalidLinkError, with: :unprocessable_entity
        
        def not_found(exception)
          render_error(exception.message, status: :not_found)
        end
  
        def unprocessable_entity(exception)
          render_error(exception.message, status: :unprocessable_entity)
        end
      end
    end
  end
end
