class ChatsController < ApplicationController

  def create
    @chat = Chat.new(title: "Untitled")
    @chat.user = current_user

    if @chat.save
      redirect_to chat_path(@chat)
    else
      @automations = current_user.automations
      render "automations/index", status: :unprocessable_entity
    end
  end
end
