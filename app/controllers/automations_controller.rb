class AutomationsController < ApplicationController
  def index
    @automations = current_user.automations
  end

  def show
    @automation = Automation.find(params[:id])
  end
end
