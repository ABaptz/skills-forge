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

  def build_conversation_history(llm_request)
    # ^ Takes the request as an argument, because two different requests need it.
    @chat.messages.each do |message|
      next if message.content.blank?

      llm_request.add_message(content: message.content, role: message.role)
      # ^ Fills the request we were given, instead of a shared instance variable.
    end
  end

  def ask_llm
    # ^ One user message means two requests: OpenAI rejects a tool and a
    # ^ thinking effort in the same call, so we send them one after the other.
    stream_answer(run_automation_tool)
  end

  # This call carries the tool and creates the automation. No thinking effort
  # here, it would make the call fail. See github.com/crmne/ruby_llm/issues/785
  def run_automation_tool
    tool_request = RubyLLM.chat
    tool_request.with_instructions(Prompt::SYSTEM_PROMPT_GENERAL)
    tool_request.with_tool(CreateAutomationTool.new(chat: @chat))
    build_conversation_history(tool_request)

    tool_request.ask(@message.content).content.to_s
    # ^ Content can be empty when the model only calls the tool, hence the to_s.
  end

  # This call carries the thinking effort and writes the answer the user reads.
  # It carries no tool, for the same reason as run_automation_tool above.
  def stream_answer(automation_summary)
    answer_request = @chat.llm
    # ^ Chat#llm is what applies the configured thinking effort.
    answer_request.with_instructions(Prompt::SYSTEM_PROMPT_GENERAL)
    build_conversation_history(answer_request)

    add_automation_note(answer_request, automation_summary)

    answer_request.ask(@message.content) do |chunk|
      # ^ Streaming happens here only, so the answer appears as it is written.
      next if chunk.content.blank? # skip empty chunks

      @assistant_message.content += chunk.content
      broadcast_replace(@assistant_message)
    end
  end

  # Tells this call what run_automation_tool just created, so it does not invent it.
  def add_automation_note(llm_request, automation_summary)
    return if automation_summary.blank?

    llm_request.add_message(
      content: "Internal note. Automation step result: #{automation_summary}",
      role: "assistant"
    )
  end

  def broadcast_replace(message)
    Turbo::StreamsChannel.broadcast_replace_to(
      @chat, target: helpers.dom_id(message),
             partial: "messages/message",
             locals: { message: message }
    )
  end
end
