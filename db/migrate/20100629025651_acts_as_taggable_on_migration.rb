class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column :name, :string
    end
    
    create_table :taggings do |t|
      t.column :tag_id, :integer
      t.column :taggable_id, :string, :limit => 40
      t.column :taggable_type, :string
            
      t.column :tagger_id, :string, :limit => 40
      t.column :tagger_type, :string  
      
      t.column :context, :string
      
      t.column :created_at, :datetime
    end
    
    add_index :taggings, :tag_id # to facilitate :include => :tags eager loading (default)
    add_index :taggings, [:taggable_id, :taggable_type, :context] # for regular lookups   
    add_index :taggings, [:tagger_id, :tagger_type] # for ownership based lookups
    
    add_index :tags, :name # for making sorted lists of tags, and LIKE q% style queries
    add_index :taggings, :context  # for direct joins against context (not thru tags)
    
  end
  
  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
