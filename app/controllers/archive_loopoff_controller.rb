class ArchiveLoopoffController < Loader::DbController
  def show
    @all_blobs = [] 
    @db.repo.commits.each do |c|
      c.tree.blobs.each do |b|
        @all_blobs << b.id
      end
    end
    @all_blobs.uniq!
  end
end
