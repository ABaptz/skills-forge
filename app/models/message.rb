class Message < ApplicationRecord
  belongs_to :chat
  validates :title, presence: true
end
