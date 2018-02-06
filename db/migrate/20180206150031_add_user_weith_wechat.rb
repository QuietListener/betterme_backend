class AddUserWeithWechat < ActiveRecord::Migration

  def change

    add_column :users,:provider,:integer,:null=>false
    add_column :users,:unionid,:string
    add_column :users,:openid,:string
    add_column :users,:country,:string
    add_column :users,:province,:string
    add_column :users,:city,:string

    add_column :users,:user_token,:string

  end

end