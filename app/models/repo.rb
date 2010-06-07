class Repo < Grit::Repo  
  def all_distinct_blobs
    distinct_blob_ids = []
    returning [] do |t|
      self.commits.each do |c|
        c.tree.blobs.each do |b|
          unless distinct_blob_ids.include?(b.id)            
            t << b
            distinct_blob_ids << b.id
          end
        end
      end
    end
  end
  
  def all_distinct_blobs_aggregated
    #                                  #  (DDD)_N.WAV                                                #  Blob file names are wavs
    self.all_distinct_blobs.group_by {|x| x.name.split('_').first}.sort.delete_if {|x| x.last.any? {|y| !y.name.match(/\.WAV/i)}}
  end
end