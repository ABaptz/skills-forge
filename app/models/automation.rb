class Automation < ApplicationRecord
  belongs_to :chat
  validates :llm_provider, inclusion: { in: %w[OpenAI openai Anthropic Google] } #  has to be in the list of the 3 providers
  validates :title, presence: true
  validates :description, presence: true
end
