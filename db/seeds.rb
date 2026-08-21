puts "Cleaning database..."

Message.destroy_all
Automation.destroy_all
Chat.destroy_all
User.destroy_all

puts "Creating users..."

sylvie = User.create!(
  email: "sylvie222@example.com",
  username: "Sylvie222",
  password: "password123",
  first_name: "Sylvie",
  last_name: "Dupont",
  job_title: "Office Manager",
  preferred_llm_provider: "OpenAI"
)

yann = User.create!(
  email: "yann777@example.com",
  username: "Yann777",
  password: "password567",
  first_name: "Yann",
  last_name: "Martin",
  job_title: "Consultant",
  preferred_llm_provider: "Anthropic"
)

puts "Creating chats..."

sylvie_energie_chat = Chat.create!(
  title: "Gestion des consommations de gaz et d'électricité",
  user: sylvie
)

yann_cuisine_chat = Chat.create!(
  title: "Recettes de cuisine du dimanche soir",
  user: yann
)

yann_nba_chat = Chat.create!(
  title: "Résumé quotidien des matchs NBA",
  user: yann
)

yann_news_chat = Chat.create!(
  title: "Analyse hebdomadaire des newsletters",
  user: yann
)

puts "Creating messages..."

Message.create!(
  role: "user",
  content: "Je souhaite suivre la consommation d'électricité, de gaz et d'eau de mon foyer.",
  chat: sylvie_energie_chat
)

Message.create!(
  role: "assistant",
  content: "Quel format de données utilisez-vous et quelles périodes de consommation doivent être comparées ?",
  chat: sylvie_energie_chat
)

Message.create!(
  role: "user",
  content: "Chaque dimanche soir, je souhaite recevoir des idées de recettes faciles à préparer pour la semaine.",
  chat: yann_cuisine_chat
)

Message.create!(
  role: "assistant",
  content: "Quels ingrédients avez-vous habituellement, pour combien de personnes cuisinez-vous et avez-vous des contraintes ou des préférences alimentaires ?",
  chat: yann_cuisine_chat
)

Message.create!(
  role: "user",
  content: "Chaque matin, je veux un résumé des moments forts les plus importants de la NBA de la veille.",
  chat: yann_nba_chat
)

Message.create!(
  role: "assistant",
  content: "Souhaitez-vous les temps forts de tous les matchs ou uniquement ceux des rencontres et des performances les plus marquantes ?",
  chat: yann_nba_chat
)

Message.create!(
  role: "user",
  content: "Chaque semaine, je souhaite analyser mes newsletters et identifier les informations les plus importantes.",
  chat: yann_news_chat
)

Message.create!(
  role: "assistant",
  content: "Comment les informations doivent-elles être hiérarchisées et quels détails le résumé final doit-il inclure ?",
  chat: yann_news_chat
)

puts "Creating automations..."

content = <<~MARKDOWN
  # Suivi de la consommation du foyer

  ## Objectif
  Importer les données de consommation d'électricité, de gaz et d'eau
  et produire un tableau récapitulatif clair et utile.

  ## Entrées attendues
  - Fichiers Excel ou CSV
  - Consommation par période
  - Type de service : électricité, gaz ou eau
  - Coûts associés lorsqu'ils sont disponibles

  ## Processus
  1. Identifier la période et le type de service.
  2. Normaliser les données.
  3. Regrouper la consommation par mois et par service.
  4. Comparer avec les périodes précédentes.
  5. Détecter les changements significatifs.

  ## Sortie attendue
  - Tableau récapitulatif
  - Tendances de consommation
  - Variations absolues et en pourcentage
  - Points clés à surveiller
  - Résumé court et clair
MARKDOWN

Automation.create!(
  chat: sylvie_energie_chat,
  title: "Suivi des factures d'eau et d'éléctricité",
  llm_provider: "OpenAI",
  content: content,
  description: "Importe les données de consommation d'électricité, de gaz et d'eau depuis des fichiers Excel ou CSV, puis génère un tableau récapitulatif mensuel avec tendances, variations et alertes sur les changements significatifs."
)
content = <<~MARKDOWN
  # Recettes du dimanche soir

  ## Objectif
  Suggérer des idées de dîner faciles et rapides chaque dimanche soir
  en fonction des ingrédients déjà disponibles à la maison.

  ## Entrées attendues
  - Ingrédients disponibles
  - Nombre de personnes
  - Contraintes alimentaires
  - Temps de cuisson disponible
  - Préférences alimentaires

  ## Processus
  1. Identifier les ingrédients utilisables.
  2. Suggérer plusieurs recettes réalistes.
  3. Privilégier les repas simples et rapides.
  4. Minimiser les achats supplémentaires.

  ## Sortie attendue
  Pour chaque recette :
  - Nom du plat
  - Temps de préparation
  - Ingrédients nécessaires
  - Étapes principales de cuisson
  - Ingrédients manquants, le cas échéant
MARKDOWN

Automation.create!(
  chat: yann_cuisine_chat,
  title: "Recettes sympa du dimanche soir",
  llm_provider: "Anthropic",
  content: content,
  description: "Propose chaque dimanche soir des idées de recettes simples et rapides pour la semaine, basées sur les ingrédients déjà disponibles, le nombre de convives et les préférences alimentaires."
)
content = <<~MARKDOWN
  # Temps forts NBA de la veille

  ## Objectif
  Résumer les moments les plus intéressants des matchs NBA joués
  la veille, sans que l'utilisateur ait besoin de regarder chaque match.

  ## Analyse attendue
  Pour chaque match pertinent :
  - Actions décisives
  - Performances individuelles remarquables
  - Séries de points ou retours importants
  - Actions spectaculaires
  - Événements ayant influencé le résultat final

  ## Priorisation
  Ne conserver que les moments réellement importants ou qui valent la peine d'être vus.

  ## Sortie attendue
  - Match
  - Moment clé
  - Joueur impliqué
  - Courte description de l'action
  - Pourquoi l'action vaut la peine d'être vue
MARKDOWN

Automation.create!(
  chat: yann_nba_chat,
  title: "Résumé des temps forts des matchs NBA de la veille",
  llm_provider: "Google",
  content: content,
  description: " Résume chaque matin les moments forts des matchs NBA de la veille : actions décisives, performances marquantes et temps forts à ne pas manquer, sans avoir à regarder les rencontres."
)
content = <<~MARKDOWN
  # Analyse intelligente des newsletters hebdomadaires

  ## Objectif
  Analyser environ 50 newsletters reçues durant la semaine
  et identifier les informations les plus importantes.

  ## Processus
  1. Lire et résumer chaque newsletter.
  2. Identifier les informations nouvelles ou significatives.
  3. Évaluer l'importance et les conséquences potentielles.
  4. Regrouper les sujets similaires.
  5. Classer les sujets par niveau de priorité.

  ## Niveaux de priorité
  - Priorité 1 : impact majeur ou conséquences significatives
  - Priorité 2 : information utile à surveiller
  - Priorité 3 : information secondaire

  ## Sortie attendue
  - Sujets classés par priorité
  - Titre de l'information
  - Source
  - Importance
  - Conséquences potentielles

  Pour chaque sujet de priorité 1, fournir un résumé d'environ 100 mots
  expliquant ce qui s'est passé, pourquoi c'est important et les conséquences possibles.
MARKDOWN

Automation.create!(
  chat: yann_news_chat,
  title: "Newsletter Tech",
  llm_provider: "OpenAI",
  content: content,
  description: "Analyse chaque semaine une cinquantaine de newsletters, hiérarchise les sujets par niveau de priorité et produit un résumé détaillé des informations à impact majeur avec leurs conséquences potentielles."
)

puts "Seed completed!"

puts "#{User.count} users created"
puts "#{Chat.count} chats created"
puts "#{Message.count} messages created"
puts "#{Automation.count} automations created"
