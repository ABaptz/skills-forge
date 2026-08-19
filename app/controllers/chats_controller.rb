class ChatsController < ApplicationController
  def create
    @chat = Chat.new(title: "Untitled")
    @chat.user = current_user

  if @chat.save
    redirect_to chat_path(@chat)
  else
    render "chats/show", status: :unprocessable_entity
  end
end
  end
end
