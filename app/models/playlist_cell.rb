class PlaylistCell < ActiveRecord::Base
  belongs_to :row, :class_name => "PlaylistRow", :foreign_key => "playlist_row_id"
  acts_as_list :scope => :playlist_row_id
  
  def commit
    @commit ||= Db[self.loopoff_db.to_sym].repo.commit(self.commit_id)
  end
  
  def blob
    # NOTE: does not do anything other than "." for paths
    @blob ||= self.commit.tree.blobs.detect {|x| x.id == self.blob_id}
  end
end
