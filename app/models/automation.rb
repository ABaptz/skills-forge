class Automation < ApplicationRecord
  include ActionView::RecordIdentifier
  after_create_commit :generate_description
  belongs_to :chat
  before_validation :default_llm_provider_from_user
  validates :llm_provider, inclusion: { in: %w[OpenAI Anthropic Google] } # has to be in the list of the 3 providers
  validates :title, presence: true
  validates :description, presence: true
  after_commit :broadcast_on_chat_show

  AUTOMATION_DESCRIPTION = <<~PROMPT
    Generate a short summary of the automation based on its content
  PROMPT

  private

  def default_llm_provider_from_user
    self.llm_provider ||= chat&.user&.preferred_llm_provider
    # ^ chat can be nil here: before_validation runs before the belongs_to presence check.
  end

  def generate_description
    return if content.blank?
    return if description.present?

    response = RubyLLM.chat.with_instructions(AUTOMATION_DESCRIPTION).ask(content)
    update(description: response.content)
  end

  def broadcast_on_chat_show
    broadcast_update_to chat, target: dom_id(chat, "automation"), partial: "chats/automation_content", locals: { automation: self }
  end
end
