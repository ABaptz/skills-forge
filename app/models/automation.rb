class Automation < ApplicationRecord
  belongs_to :chat
  validates :llm_provider, inclusion: { in: %w[OpenAI openai Anthropic Google] } #  has to be in the list of the 3 providers
  validates :title, presence: true
  validates :description, presence: true
  after_commit :broadcast_on_chat_show

  private

  def broadcast_on_chat_show
    broadcast_update_to chat, target: dom_id(self), partial: "chats/automation_content", locals: { automation: self }
  end
end
