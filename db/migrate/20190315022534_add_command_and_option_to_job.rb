class AddCommandAndOptionToJob < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :command_and_option, :string
  end
end
