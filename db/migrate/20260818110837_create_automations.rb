class CreateAutomations < ActiveRecord::Migration[8.1]
  def change
    create_table :automations do |t|
      t.references :chat, null: false, foreign_key: true
      t.string :title
      t.string :llm_provider
      t.text :content

      t.timestamps
    end
  end
end
