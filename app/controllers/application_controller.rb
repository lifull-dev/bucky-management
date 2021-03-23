# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render404
  rescue_from ActionController::RoutingError, with: :render404

  unless Rails.env.development?
    def render404(exception = nil)
      logger.info "Rendering 404 with exception: #{exception.message}" if exception
      render template: 'errors/error_404', status: :not_found, layout: 'application', formats: :html
    end
  end
end
