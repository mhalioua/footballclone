class AddIndicesToTables < ActiveRecord::Migration[5.1]
  def change
  	add_index :games, :home_team
  	add_index :games, :game_date
  	add_index :games, :game_type
  	add_index :games, :away_team
  end
end
