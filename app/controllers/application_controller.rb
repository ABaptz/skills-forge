class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def configure_permitted_parameters
  # For additional fields in app/views/devise/registrations/new.html.erb
  devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :job_title, :preferred_llm_provider, :username])

  # For additional in app/views/devise/registrations/edit.html.erb
  devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :job_title, :preferred_llm_provider, :username])
  end
end
