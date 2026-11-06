require "test_helper"

class AppMyLifeFlowsTest < ActionDispatch::IntegrationTest
  setup do
    IdeaStep.delete_all
    Idea.delete_all
    FinancialTransaction.delete_all
    AutomationRule.delete_all
    User.delete_all
  end

  test "unauthenticated visitor is redirected to login and can sign up" do
    get root_path
    assert_redirected_to login_path

    get login_path
    assert_response :success
    assert_match "¿Olvidaste tu contraseña?", response.body
    assert_match "Mantener mi sesión iniciada", response.body
    assert_match "Google", response.body
    assert_match "GitHub", response.body

    get signup_path
    assert_response :success
    assert_match "Crea tu cuenta.", response.body

    assert_difference -> { User.count }, 1 do
      post signup_path, params: {
        user: {
          name: "Alex",
          email: "alex@example.com",
          password: "password123",
          password_confirmation: "password123"
        },
        remember_me: "1"
      }
    end
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_match "Hola, Alex.", response.body
    assert_match "Una chispa. Todo en orden.", response.body
  end

  test "social sign in and password reset flows work end to end" do
    # 1. Social quick login (Google) without external API keys
    assert_difference -> { User.count }, 1 do
      post social_auth_path, params: {
        provider: "google",
        name: "Bryan Marc",
        email: "bryan@gmail.com"
      }
    end
    assert_redirected_to root_path
    follow_redirect!
    assert_match "Hola, Bryan Marc.", response.body

    delete logout_path

    # 2. Password reset flow with signed expiring token
    user = User.find_by!(email: "bryan@gmail.com")
    token = user.generate_token_for(:password_reset)

    get edit_password_reset_path(token: token)
    assert_response :success
    assert_match "Nueva contraseña.", response.body

    patch password_reset_path(token: token), params: {
      password: "NuevaClaveSegura123!",
      password_confirmation: "NuevaClaveSegura123!"
    }
    assert_redirected_to root_path
    assert user.reload.authenticate("NuevaClaveSegura123!")
  end

  test "private data isolation between different user accounts" do
    # 1. User A (Alex) signs up and creates an idea, a task, and a money entry
    post signup_path, params: {
      user: {
        name: "Alex",
        email: "alex@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    post entries_path, params: { entry_type: "ideas", title: "Idea privada de Alex" }
    post entries_path, params: { entry_type: "tasks", title: "Tarea privada de Alex" }
    post entries_path, params: { entry_type: "money", title: "Cena de Alex", amount: "25,00" }

    alex_idea = Idea.find_by!(title: "Idea privada de Alex")
    assert_equal 1, User.find_by!(email: "alex@example.com").ideas.count

    # Log out Alex
    delete logout_path
    assert_redirected_to login_path

    # 2. User B (Lucía) signs up
    post signup_path, params: {
      user: {
        name: "Lucía",
        email: "lucia@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    follow_redirect!
    assert_match "Hola, Lucía.", response.body

    # Lucía sees 0 ideas, 0 tasks, and 0,00 € (cannot see Alex's data)
    get ideas_path
    assert_response :success
    assert_match "0 guardadas", response.body
    assert_no_match "Idea privada de Alex", response.body

    get tasks_path
    assert_response :success
    assert_match "0 pendientes", response.body
    assert_no_match "Tarea privada de Alex", response.body

    get finances_path
    assert_response :success
    assert_match "$0.00", response.body
    assert_no_match "Cena de Alex", response.body

    # Lucía cannot delete Alex's idea
    assert_no_difference -> { Idea.count } do
      delete idea_path(alex_idea)
      assert_response :not_found
    end
  end
end
