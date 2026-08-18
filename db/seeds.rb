puts "Cleaning database..."

Message.destroy_all
Automation.destroy_all
Chat.destroy_all
User.destroy_all

puts "Creating users..."

sylvie = User.create!(
  email: "sylvie222@example.com",
  username: "Sylvie222",
  password: "password123"
)

yann = User.create!(
  email: "yann777@example.com",
  username: "Yann777",
  password: "password567"
)

puts "Creating chats..."

sylvie_energie_chat = Chat.create!(
  title: "Sylvie, gas and electricity consumption management",
  user: sylvie
)

yann_recipes_chat = Chat.create!(
  title: "Sunday night cooking recipes",
  user: yann
)

yann_nba_chat = Chat.create!(
  title: "NBA highlights from the previous day",
  user: yann
)

yann_news_chat = Chat.create!(
  title: "Weekly newsletter intelligence",
  user: yann
)

puts "Creating messages..."

Message.create!(
  role: "user",
  content: "Every Sunday evening, I want to receive easy recipe ideas to cook for my week.",
  chat: yann_recipes_chat
)

Message.create!(
  role: "assistant",
  content: "What ingredients do you usually have, how many people are you cooking for, and do you have any dietary constraints or preferences?",
  chat: yann_recipes_chat
)

puts "Creating automations..."

Automation.create!(
  chat: sylvie_energie_chat,
  title: "Household Electricity, Gas and Water Tracking",
  llm_provider: "OpenAI",
  content: <<~MARKDOWN
    # Household Consumption Tracking

    ## Objective
    Import electricity, gas and water consumption data
    and produce a clear and useful summary table.

    ## Expected Inputs
    - Excel or CSV files
    - Consumption by period
    - Utility type: electricity, gas or water
    - Related costs when available

    ## Process
    1. Identify the period and utility type.
    2. Normalize the data.
    3. Group consumption by month and utility.
    4. Compare with previous periods.
    5. Detect significant changes.

    ## Expected Output
    - Summary table
    - Consumption trends
    - Absolute and percentage changes
    - Key points to monitor
    - Short, clear summary
  MARKDOWN
)

Automation.create!(
  chat: yann_recipes_chat,
  title: "Easy Sunday Evening Recipes",
  llm_provider: "Anthropic",
  content: <<~MARKDOWN
    # Sunday Evening Recipes

    ## Objective
    Suggest easy and quick dinner ideas every Sunday evening
    based on the ingredients already available at home.

    ## Expected Inputs
    - Available ingredients
    - Number of people
    - Dietary constraints
    - Available cooking time
    - Food preferences

    ## Process
    1. Identify usable ingredients.
    2. Suggest several realistic recipes.
    3. Prioritize simple and quick meals.
    4. Minimize additional shopping.

    ## Expected Output
    For each recipe:
    - Dish name
    - Preparation time
    - Required ingredients
    - Main cooking steps
    - Missing ingredients, if any
  MARKDOWN
)

Automation.create!(
  chat: yann_nba_chat,
  title: "Previous Day NBA Highlights Summary",
  llm_provider: "Google",
  content: <<~MARKDOWN
    # NBA Highlights from the Previous Day

    ## Objective
    Summarize the most interesting moments from NBA games played
    the previous day without requiring the user to watch every game.

    ## Expected Analysis
    - Decisive plays
    - Outstanding individual performances
    - Important runs or comebacks
    - Spectacular actions
    - Events that influenced the final result

    ## Prioritization
    Keep only the moments that are genuinely important or worth watching.

    ## Expected Output
    - Game
    - Key moment
    - Player involved
    - Short description of the action
    - Why the action is worth watching
  MARKDOWN
)

Automation.create!(
  chat: yann_news_chat,
  title: "Weekly Newsletter Intelligence",
  llm_provider: "OpenAI",
  content: <<~MARKDOWN
    # Weekly Newsletter Intelligence

    ## Objective
    Analyze approximately 50 newsletters received during the week
    and identify the information that matters most.

    ## Process
    1. Read and summarize each newsletter.
    2. Identify new or significant information.
    3. Assess importance and potential consequences.
    4. Group similar topics.
    5. Rank topics by priority level.

    ## Priority Levels
    - Priority 1: major impact or significant consequences
    - Priority 2: useful information to monitor
    - Priority 3: secondary information

    ## Expected Output
    - Topics ranked by priority
    - Information title
    - Source
    - Importance
    - Potential consequences

    For each **Priority 1** topic, provide an approximately
    **100-word summary** explaining:
    - what happened
    - why it matters
    - the possible consequences
  MARKDOWN
)

puts "Seed completed!"

puts "#{User.count} users created"
puts "#{Chat.count} chats created"
puts "#{Message.count} messages created"
puts "#{Automation.count} automations created"