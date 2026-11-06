class CreateAppMyLifeSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :ideas do |t|
      t.string :title, null: false
      t.text :summary, null: false
      t.text :essential_summary
      t.text :transcript
      t.string :category, null: false, default: "Proyectos"
      t.string :status_tag, null: false, default: "Por explorar"
      t.string :source_kind, null: false, default: "Nota de voz"
      t.string :captured_label, null: false, default: "Ahora"
      t.string :captured_meta, default: "6 nov, 9:41 · Capturada por voz · 18 s"
      t.integer :duration_seconds, default: 18
      t.string :icon_name, null: false, default: "route"
      t.boolean :featured_today, null: false, default: false
      t.boolean :visible_in_recent, null: false, default: true
      t.string :next_step_preview
      t.boolean :steps_confirmed, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :ideas, :category
    add_index :ideas, :featured_today
    add_index :ideas, :position

    create_table :idea_steps do |t|
      t.references :idea, null: false, foreign_key: true
      t.string :description, null: false
      t.boolean :completed, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    create_table :financial_transactions do |t|
      t.string :concept, null: false
      t.string :category, null: false
      t.string :kind, null: false, default: "expense"
      t.integer :amount_cents, null: false
      t.string :date_label, null: false, default: "Hoy"
      t.string :icon_name, null: false, default: "shopping-basket"
      t.boolean :visible_in_recent, null: false, default: true
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :financial_transactions, :kind
    add_index :financial_transactions, :category

    create_table :automation_rules do |t|
      t.string :title, null: false
      t.boolean :active, null: false, default: true
      t.string :trigger_condition, null: false
      t.string :action_result, null: false
      t.string :confirmation_note, null: false
      t.string :icon_name, null: false, default: "mic-rule"
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
