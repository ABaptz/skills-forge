class CreateAutomationTool < RubyLLM::Tool
  description "Creates an automation based on the information given in the chat."
  param :title, desc: "The title of the automation"
  param :description, desc: "The description of the automation"
  param :content, desc: "The content of the automation"
  param :llm_provider, desc: "The llm_provider of the automation"

  def initialize(chat:)
    @chat = chat
  end

  def execute(title:, description:, content:, llm_provider:)
    Automation.create!(
      title: title,
      chat: @chat,
      description: description,
      content: content,
      llm_provider: llm_provider
    )
    { title: title, description: description, content: content, llm_provider: llm_provider }
  rescue ActiveRecord::RecordNotFound
    { error: "Chat not found" }
  rescue ActiveRecord::RecordInvalid => e
    { error: e.message }
  end
end
