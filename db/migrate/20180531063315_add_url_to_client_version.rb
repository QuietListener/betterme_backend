class AddUrlToClientVersion < ActiveRecord::Migration
  def change
    add_column :client_versions,:download_url ,:string,limit: 2048
  end
end
