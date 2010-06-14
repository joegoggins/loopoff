class CreatePlaylistRows < ActiveRecord::Migration
  def self.up
    create_table :playlist_rows do |t|
      t.belongs_to :playlist
      t.string :aggregation_string
      t.string :commit_id
      t.string :loopoff_db
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :playlist_rows
  end
end
