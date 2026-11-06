require "test_helper"

class AppMyLifeFlowsTest < ActionDispatch::IntegrationTest
  setup do
    IdeaStep.delete_all
    Idea.delete_all
    FinancialTransaction.delete_all
    AutomationRule.delete_all
  end

  test "bitacora personal clean screens render with empty state" do
    get root_path
    assert_response :success
    assert_match "Hola, Alex.", response.body
    assert_match "Una chispa. Todo en orden.", response.body
    assert_match "Tu próxima gran idea", response.body

    get ideas_path
    assert_response :success
    assert_match "0 guardadas", response.body
    assert_match "Todo despejado", response.body

    get tasks_path
    assert_response :success
    assert_match "0 pendientes", response.body
    assert_match "Todo despejado", response.body

    get finances_path
    assert_response :success
    assert_match "Balance registrado", response.body
    assert_match "0,00 €", response.body
    assert_match "Todo despejado", response.body
  end

  test "unified composer creates ideas, tasks, and money movements" do
    # 1. Create an Idea via Composer
    assert_difference -> { Idea.count }, 1 do
      post entries_path, params: { entry_type: "ideas", title: "Una huerta pequeña en el balcón" }
    end
    assert_redirected_to ideas_path
    follow_redirect!
    assert_match "Una huerta pequeña en el balcón", response.body

    # 2. Create a Task via Composer and toggle it
    assert_difference -> { IdeaStep.count }, 1 do
      post entries_path, params: { entry_type: "tasks", title: "Llamar al dentista" }
    end
    assert_redirected_to tasks_path
    task = IdeaStep.order(:id).last
    patch toggle_task_path(task)
    assert task.reload.completed?

    # 3. Create a Money movement via Composer
    assert_difference -> { FinancialTransaction.count }, 1 do
      post entries_path, params: { entry_type: "money", title: "Café", amount: "4,50" }
    end
    assert_redirected_to finances_path
    follow_redirect!
    assert_match "Café", response.body
    assert_match "-4,50 €", response.body
  end
end
