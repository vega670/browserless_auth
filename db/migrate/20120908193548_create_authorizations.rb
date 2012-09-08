class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.string :state
      t.string :token
      t.text :error

      t.timestamps
    end
    add_index :authorizations, :state
  end
end
