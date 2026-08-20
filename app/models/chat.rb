class Chat < ApplicationRecord
  belongs_to :user

  has_many :messages, dependent: :destroy
  has_many :automations, dependent: :destroy

    def llm # this method takes the parameter we set in the config to easily adapt the thinking effort
    RubyLLM.chat.with_thinking(effort: Rails.application.config.x.llm.thinking_effort)
  end
end
