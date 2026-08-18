class Automation < ApplicationRecord
  belongs_to :chat
  validates :llm_provider, uniqueness: { in: %w[OpenAI Anthropic Google] } #  has to be in the list of the 3 providers
  validates :title, presence: true

end
