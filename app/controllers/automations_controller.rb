class AutomationsController < ApplicationController
  def index
    @automations = Automation.all
  end
end
