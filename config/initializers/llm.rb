# LLM settings. You can change any of these from .env, without touching the code.

# How hard the model thinks before answering.
# Possible values: :none, :low, :medium, :high
# :none is the fastest and cheapest, :high follows instructions best but costs more and is slower.
Rails.application.config.x.llm.thinking_effort = ENV.fetch("LLM_THINKING_EFFORT", "high").to_sym


# The maximum number of messages one conversation can ever contain.
# Possible values: any whole number. Once reached, the user cannot send more.
# This is a safety net, so a conversation cannot loop forever and keep spending money.
Rails.application.config.x.llm.max_messages    = ENV.fetch("LLM_MAX_MESSAGES", "40").to_i
