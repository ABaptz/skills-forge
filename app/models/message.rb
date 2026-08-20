class Message < ApplicationRecord
  after_create_commit :broadcast_append_to_chat
  belongs_to :chat
  validates :content, presence: true, if: :user_message?

  private

  def user_message?
    role == 'user'
  end

  def broadcast_append_to_chat
    broadcast_append_to chat, target: "messages", partial: "messages/message", locals: { message: self }
  end
end
