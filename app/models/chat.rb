class Chat < ApplicationRecord
  belongs_to :user
  has_many :automations, dependent: :destroy
end
