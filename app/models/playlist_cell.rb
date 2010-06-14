class PlaylistCell < ActiveRecord::Base
  belongs_to :playlist_row
  
  def commit
    @commit ||= Db[self.loopoff_db.to_sym].repo.commit(self.commit_id)
  end
  
  def blob
    # NOTE: does not do anything other than "." for paths
    @blob ||= self.commit.tree.blobs.detect {|x| x.id == self.blob_id}
  end
end
