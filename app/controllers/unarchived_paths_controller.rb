class UnarchivedPathsController < Loader::DbController
  def index
    @unarchived_paths = @db.unarchived_paths
  end

  def show
  end

end
