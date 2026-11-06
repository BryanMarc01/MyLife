# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_06_153500) do
  create_table "automation_rules", force: :cascade do |t|
    t.string "title", null: false
    t.boolean "active", default: true, null: false
    t.string "trigger_condition", null: false
    t.string "action_result", null: false
    t.string "confirmation_note", null: false
    t.string "icon_name", default: "mic-rule", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_automation_rules_on_user_id"
  end

  create_table "financial_transactions", force: :cascade do |t|
    t.string "concept", null: false
    t.string "category", null: false
    t.string "kind", default: "expense", null: false
    t.integer "amount_cents", null: false
    t.string "date_label", default: "Hoy", null: false
    t.string "icon_name", default: "shopping-basket", null: false
    t.boolean "visible_in_recent", default: true, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["category"], name: "index_financial_transactions_on_category"
    t.index ["kind"], name: "index_financial_transactions_on_kind"
    t.index ["user_id"], name: "index_financial_transactions_on_user_id"
  end

  create_table "idea_steps", force: :cascade do |t|
    t.integer "idea_id"
    t.string "description", null: false
    t.boolean "completed", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["idea_id"], name: "index_idea_steps_on_idea_id"
    t.index ["user_id"], name: "index_idea_steps_on_user_id"
  end

  create_table "ideas", force: :cascade do |t|
    t.string "title", null: false
    t.text "summary", null: false
    t.text "essential_summary"
    t.text "transcript"
    t.string "category", default: "Proyectos", null: false
    t.string "status_tag", default: "Por explorar", null: false
    t.string "source_kind", default: "Nota de voz", null: false
    t.string "captured_label", default: "Ahora", null: false
    t.string "captured_meta", default: "6 nov, 9:41 · Capturada por voz · 18 s"
    t.integer "duration_seconds", default: 18
    t.string "icon_name", default: "route", null: false
    t.boolean "featured_today", default: false, null: false
    t.boolean "visible_in_recent", default: true, null: false
    t.string "next_step_preview"
    t.boolean "steps_confirmed", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "audio_data"
    t.integer "user_id"
    t.index ["category"], name: "index_ideas_on_category"
    t.index ["featured_today"], name: "index_ideas_on_featured_today"
    t.index ["position"], name: "index_ideas_on_position"
    t.index ["user_id"], name: "index_ideas_on_user_id"
  end

  create_table "user_settings", force: :cascade do |t|
    t.string "user_name", default: "Lucía", null: false
    t.integer "monthly_budget_cents", default: 120000, null: false
    t.boolean "discrete_finance_mode", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "monthly_budget_cents", default: 120000, null: false
    t.boolean "discrete_finance_mode", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "automation_rules", "users"
  add_foreign_key "financial_transactions", "users"
  add_foreign_key "idea_steps", "ideas"
  add_foreign_key "idea_steps", "users"
  add_foreign_key "ideas", "users"
end
