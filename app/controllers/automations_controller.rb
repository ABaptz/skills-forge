class AutomationsController < ApplicationController
  def index
    @automations = current_user.automations
  end
end
