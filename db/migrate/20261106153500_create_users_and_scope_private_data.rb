class CreateUsersAndScopePrivateData < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :monthly_budget_cents, default: 120_000, null: false
      t.boolean :discrete_finance_mode, default: false, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true

    add_reference :ideas, :user, foreign_key: true
    add_reference :idea_steps, :user, foreign_key: true
    add_reference :financial_transactions, :user, foreign_key: true
    add_reference :automation_rules, :user, foreign_key: true
  end
end
