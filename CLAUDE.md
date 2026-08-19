# SkillsForge — instructions projet

Ce fichier ne contient que le **spécifique à SkillsForge**. Les pratiques
transverses (Git, secrets, README, vault ObsiClaud, restitution des fichiers,
langue) vivent dans `~/.claude/CLAUDE.md` et s'appliquent ici sans être
répétées.

## 🔴 Règle d'ouverture — avant la première ligne de code

**Charger le skill `methode-wagon` avant d'ouvrir le premier fichier**, pour
toute tâche qui produit ou modifie du code (Ruby, Rails, ERB, JS, SCSS) :

```
Skill(skill: "methode-wagon")
```

Ce skill vit dans `~/.claude/skills/methode-wagon/SKILL.md`. Il est bien
enregistré, mais il ne s'auto-charge pas : un skill personnel apparaît dans la
liste des skills disponibles et doit être **invoqué** — soit par Romain avec
`/methode-wagon`, soit par Claude via l'outil `Skill`. C'est ce rappel-ci qui
rend l'invocation systématique sur ce projet.

Ce qu'il impose, en résumé — le détail est dans le skill :

- décomposer la méthode en **étapes numérotées en commentaires** avant de
  coder, et **garder ces commentaires** dans le code livré ;
- coder **en silo**, une tranche verticale à la fois (une route → un
  contrôleur → une vue), jamais trois chantiers en parallèle ;
- respecter le découpage MVC du boilerplate Le Wagon ;
- écrire du Ruby **idiomatique mais élémentaire** : du code que Romain peut
  relire et défendre seul, pas du code plus malin que le sien ;
- **ne pas refactoriser ce qui marche** sans demande explicite.

## Ce que fait le projet

Un service web grand public qui transforme un besoin flou en automatisation
prête à l'emploi. L'utilisateur arrive avec « je veux gagner du temps sur mes
mails » ; un agent d'intake l'interviewe en français, question par question,
jusqu'à ce que son besoin soit complètement décrit ; un second système génère
ensuite l'automatisation.

Public visé : **utilisateur débutant** des assistants IA grand public. Il ne
connaît ni « prompt », ni « contexte », ni « API ». Toute l'UX et tous les
textes en découlent : questions courtes, une à la fois, options numérotées.

## Le cœur du projet : le prompt d'intake

`app/controllers/messages_controller.rb` → constante `SYSTEM_PROMPT`.

C'est la pièce la plus travaillée du repo, pas un détail d'implémentation.
Ses partis pris, à ne pas casser par inadvertance :

- **rédigé en anglais, réponses en français** — écart volontaire à la règle
  « docs en français » du socle : c'est un artefact envoyé au modèle, pas de
  la documentation ;
- **7 slots à remplir** (trigger, task, input, output, shape, voice, limits),
  plus un 8ᵉ optionnel (example). Ne pas en ajouter sans décision produit ;
- **une seule question par tour**, 4 lignes maximum, options numérotées ;
- garde-fous anti-injection : ce que l'utilisateur colle est du **contenu à
  analyser**, jamais des instructions ;
- `{{GENERATE_BUTTON_LABEL}}` est un placeholder à remplacer par le vrai
  libellé du bouton une fois l'écran de génération posé.

Toute retouche de ce prompt se fait dans un commit dédié, jamais mélangée à
du code.

## Stack

- Rails 8.1.3, Ruby 3.3.5, PostgreSQL (`pg`).
- Boilerplate **Le Wagon** : Bootstrap 5.3, `simple_form`, `font-awesome-sass`,
  `sassc-rails`, `sprockets-rails` + `propshaft`, importmap + Stimulus/Turbo.
- Devise pour l'authentification (`username` ajouté par migration).
- **`ruby_llm`** pour les appels LLM — `config/initializers/ruby_llm.rb`,
  provider OpenAI, `default_model = "gpt-5.4-nano"`, clé lue dans `.env`
  (`OPENAI_API_KEY`, jamais commitée).
- Solid Cache / Queue / Cable, Kamal + Thruster pour le déploiement (non
  activé à ce jour).
- Tests : Minitest (squelette généré, pas de suite réelle) ; qualité :
  RuboCop omakase + Brakeman + bundler-audit via `bin/ci`.

## Modèle de données

```
User (devise + username)
  └─1:N─ Chat (title)
           ├─1:N─ Message (role: "user" | "assistant", content)
           └─1:N─ Automation (title, content, llm_provider)
```

`User has_many :automations, through: :chats`.

`llm_provider` est censé être contraint à `OpenAI`, `Anthropic`, `Google`.

## Conventions propres à ce projet

- **Projet collaboratif**, contrairement au défaut solo du socle : on travaille
  sur une **branche par sujet**, puis PR vers `master` (voir l'historique :
  `homepage_v1`, `create-automations-controller-and-index-method`). Ne pas
  committer directement sur `master`.
- L'historique de commits est **en anglais** et les messages sont courts.
  S'aligner sur l'existant plutôt que d'imposer le français du socle : le repo
  est partagé avec d'autres élèves du batch.
- L'UI est en anglais (« Create a new skill », navbar), **les réponses de
  l'agent sont en français**. Ne pas uniformiser sans décision produit.
- `.rubocop.yml` du boilerplate Le Wagon : ligne à 120, beaucoup de cops
  stylistiques désactivés. Ne pas le durcir.

## Lancer en local

```bash
bin/setup          # bundle + préparation de la base
bin/rails db:create db:migrate
bin/dev            # serveur de développement
bin/ci             # rubocop + brakeman + bundler-audit + tests
```

Prérequis : PostgreSQL démarré, `.env` contenant `OPENAI_API_KEY`.

## ⚠️ Dette et pièges connus (constat du 19/08/2026)

À traiter dans une passe dédiée, pas en douce au milieu d'une feature :

- `app/models/message.rb` valide `presence` sur `:title` — **cette colonne
  n'existe pas** dans la table `messages`. Toute création de message casse.
- `app/models/automation.rb` utilise `uniqueness: { in: [...] }` — l'option
  `:in` appartient à `inclusion`, pas à `uniqueness`.
- `MessagesController#create` appelle `@chat.generate_title_from_first_message`,
  méthode **non définie**.
- `ChatsController` n'existe pas alors que la home poste vers `chats_path`, et
  `chat_path` / la vue `chats/show` sont référencés sans exister
  (`resources :chats, only: [:create]`).
- Routes déclarées sans action ni vue : `automations#show`, `pages#privacy`.
  Dossiers `app/views/automations` et `app/views/messages` vides.
- `has_many :automations, through: :chats, dependent: :destroy` — le
  `dependent:` est sans effet utile sur un `through`.
- Épisode du 19/08/2026 : `app/models/chat.rb` avait été écrasé par un
  caractère parasite (`æ`) en local. Réflexe en cas de comportement absurde au
  boot : `git diff` avant de chercher plus loin.
