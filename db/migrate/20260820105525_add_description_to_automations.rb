class AddDescriptionToAutomations < ActiveRecord::Migration[8.1]
  def change
    add_column :automations, :description, :text
  end
end
