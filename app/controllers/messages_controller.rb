class MessagesController < ApplicationController
  def create
    # Scope the chat to the current user so one user cannot post into another's chat.
    @chat = current_user.chats.find(params[:chat_id])
    # # Persist the user turn first.
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      # Send the turn to the LLM with the system prompt as instructions.
      @ruby_llm_chat = RubyLLM.chat
      build_conversation_history
      response = @ruby_llm_chat.with_instructions(Prompt::SYSTEM_PROMPT_GENERAL).ask(@message.content)
      # Persist the assistant turn.
      Message.create(role: "assistant", content: response.content, chat: @chat)
      # @chat.generate_title_from_first_message
      redirect_to chats_path
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(content: message.content, role: message.role)
    end
  end
end
