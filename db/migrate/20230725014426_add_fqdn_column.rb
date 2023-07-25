class AddFqdnColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :jobs, :base_fqdn, :string
  end
end
