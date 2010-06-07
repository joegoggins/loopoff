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
    # returning [] do |t|
    #   self.commits.each do |c|
    #     tree_blobs = []
    #     c.tree.blobs.each do |b|
    #       tree_blobs << b
    #     end
    #     t << tree_blobs
    #   end
    #         
    # end
    # self.all_distinct_blobs.group_by {|x| x.name.split('_').first}.sort.delete_if {|x| x.first.match /\./}
  end
end