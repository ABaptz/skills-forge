class AddProfileColumnsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :last_name, :string
    add_column :users, :first_name, :string
    add_column :users, :job_title, :string
    add_column :users, :preferred_llm_provider, :string
  end
end
