class Automation < ApplicationRecord
  belongs_to :chat
  validates :llm_provider, inclusion: { in: %w[OpenAI Anthropic Google] } #  has to be in the list of the 3 providers
  validates :title, presence: true
  validates :description, presence: true

  AUTOMATION_DESCRIPTION = <<~PROMPT
    Generate a short summarize of the automation based on its content
  PROMPT

  private

  def generate_description
    return if content.blank?
    return if description.present?

    response = RubyLLM.chat.with_instructions(DESCRIPTION_PROMPT).ask(content)
    update(description: response.content)
  end
end
