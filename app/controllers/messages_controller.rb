class MessagesController < ApplicationController
  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      @assistant_message = @chat.messages.create(role: "assistant", content: "")

      response = ask_llm
      @assistant_message.update(content: response.content)
      broadcast_replace(@assistant_message)

      @chat.generate_title_from_first_message

      respond_to do |format|
        format.turbo_stream # renders `app/views/messages/create.turbo_stream.erb`
        format.html { redirect_to chat_path(@chat) }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("new_message_container",
                                                   partial: "messages/form",
                                                   locals: { chat: @chat, message: @message })}
        format.html { render "chats/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def build_conversation_history
    @chat.messages.each do |message|
      next if message.content.blank?

      @ruby_llm_chat.add_message(content: message.content, role: message.role)
    end
  end

  def ask_llm
    @ruby_llm_chat = RubyLLM.chat

    build_conversation_history
    @ruby_llm_chat.with_tool(CreateAutomationTool.new(chat: @chat))
    @ruby_llm_chat.with_instructions(Prompt::SYSTEM_PROMPT_GENERAL)

    @ruby_llm_chat.ask(@message.content) do |chunk|
      next if chunk.content.blank? # skip empty chunks

      @assistant_message.content += chunk.content
      broadcast_replace(@assistant_message)
    end
  end

  def broadcast_replace(message)
    Turbo::StreamsChannel.broadcast_replace_to(
      @chat, target: helpers.dom_id(message),
             partial: "messages/message",
             locals: { message: message }
    )
  end
end
