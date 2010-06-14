class PlaylistRow < ActiveRecord::Base
  belongs_to :playlist
  acts_as_list :scope => :playlist
  
  has_many :cells, :class_name => "PlaylistCell", :order => "position",:dependent => :delete_all

  def commit
    @commit ||= Db[self.loopoff_db.to_sym].repo.commit(self.commit_id)
  end
  
  def title_from_commit_message
    self.commit.extract_row_name_from_message(self.aggregation_string)
  end
end
