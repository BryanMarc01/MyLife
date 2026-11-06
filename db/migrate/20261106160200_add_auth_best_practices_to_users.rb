class AddAuthBestPracticesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :remember_digest, :string
    add_column :users, :auth_provider, :string
    add_column :users, :auth_uid, :string
    add_column :users, :last_login_at, :datetime
  end
end
