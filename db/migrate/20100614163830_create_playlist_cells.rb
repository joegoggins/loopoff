class CreatePlaylistCells < ActiveRecord::Migration
  def self.up
    create_table :playlist_cells do |t|
      t.belongs_to :playlist_row
      t.string :blob_id
      t.string :commit_id
      t.string :loopoff_db
      t.string :name
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :playlist_cells
  end
end
