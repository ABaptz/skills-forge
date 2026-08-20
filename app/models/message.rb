class Message < ApplicationRecord
  belongs_to :chat
  validates :content, presence: true

  validate :chat_not_full, on: :create

  private

  def chat_not_full
    return if chat.blank?

    limit = Rails.application.config.x.llm.max_messages
    return if chat.messages.count < limit

    errors.add(:base, "Cette conversation a atteint sa limite de #{limit} messages.")
  end
end
