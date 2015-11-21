class ErrorsController < ActionController::Base
  layout 'application'

  # NOTE: rescue_fromは下から評価される
  rescue_from StandardError,                  with: :render_500
  rescue_from ActiveRecord::RecordNotFound,   with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

  def render_404(exception = nil)
    if exception
      logger.info "Rendering 404 with exception: #{exception.message}"
      notify_exception(exception)
    end
    render_exception template: 'errors/error_404', status: 404
  end

  def render_500(exception = nil)
    if exception
      logger.info "Rendering 500 with exception: #{exception.message}"
      notify_exception(exception)
    end
    render_exception template: 'errors/error_500', status: 500
  end

  def show
    raise env['action_dispatch.exception']
  end

  private

  def render_exception(options)
    status = options.delete(:status)
    template = options.delete(:template)
    options = if request.xhr?
                {
                  json: nil,
                  status: status
                }
              else
                {
                  template: template,
                  status: status,
                }.merge!(options)
              end
    render options
  end

  def notify_exception(exception)
    notify_by_airbrake(exception)
  end

  def notify_by_airbrake(exception)
    if defined?(Airbrake::Rails::Middleware) &&
       Rails.application.config.middleware.include?(Airbrake::Rails::Middleware)
      notify_airbrake(exception)
    end
  end
end
