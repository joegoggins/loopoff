class Repo < Grit::Repo    
  # WARNING DUPLICATE FROM unarchived path
  def distinct_blobs
    if @distinct_blobs.blank?
      distinct_blob_ids = []
      @distinct_blobs = []
      self.commits.each do |c|
        c.tree.blobs.each do |b|
          unless distinct_blob_ids.include?(b.id)            
            @distinct_blobs << b
            distinct_blob_ids << b.id
          end
        end
      end      
    end
    @distinct_blobs
  end
  
  def distinct_blob_ids
    self.distinct_blobs.map {|x| x.id}
  end  
  def distinct_blobs_aggregated
    #                                  #  (DDD)_N.WAV                                                #  Blob file names are wavs
    self.distinct_blobs.group_by {|x| x.name.split('_').first}.sort.delete_if {|x| x.last.any? {|y| !y.name.match(/\.WAV/i)}}
  end  
end