class ArchiveLoopoffController < Loader::DbController
  def show
    @collection = @db.repo
    render :partial => 'loopoff_table/show', :layout => true
  end
end
