class ArchiveLoopoffController < Loader::DbController
  def show
    @all_distinct_blobs_aggregated = @db.repo.all_distinct_blobs_aggregated
  end
end
