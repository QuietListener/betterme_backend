class CreateClientVersions < ActiveRecord::Migration
  def change
    create_table :client_versions do |t|
      t.integer :client_type
      t.integer :version
      t.string    :desc
      t.timestamps null: false
    end
  end
end
