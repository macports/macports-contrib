class AddSummaryToTickets < ActiveRecord::Migration
  def self.up
    add_column :tickets, :summary, :string
  end

  def self.down
    remove_column :tickets, :summary
  end
end