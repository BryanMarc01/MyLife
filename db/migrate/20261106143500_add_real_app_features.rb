class AddRealAppFeatures < ActiveRecord::Migration[8.1]
  def change
    add_column :ideas, :audio_data, :text

    create_table :user_settings do |t|
      t.string :user_name, null: false, default: "Lucía"
      t.integer :monthly_budget_cents, null: false, default: 120_000
      t.boolean :discrete_finance_mode, null: false, default: false

      t.timestamps
    end
  end
end
