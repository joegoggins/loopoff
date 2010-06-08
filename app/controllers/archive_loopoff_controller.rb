class ArchiveLoopoffController < Loader::DbController
  def show
    @distinct_blobs_aggregated = @db.repo.distinct_blobs_aggregated
    @table = Lt::Table.new
    @distinct_blobs_aggregated.each do |b|

    end
    
  end
end
