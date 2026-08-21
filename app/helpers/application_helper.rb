module ApplicationHelper
  def render_markdown(text)
    Kramdown::Document.new(text, input: 'GFM', syntax_highlighter: "rouge").to_html
  end

  def tutorial_path_for(automation)
    case automation.llm_provider
    when "Anthropic" then tutorials_claude_path
    when "OpenAI"    then tutorials_chatgpt_path
    when "Google"    then tutorials_gemini_path
    end
  end
end
