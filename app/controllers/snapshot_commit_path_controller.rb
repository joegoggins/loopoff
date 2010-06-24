class SnapshotCommitPathController < Loader::DbController
  # for rendering a tree within a commit
  # something like http://localhost:3000/db/rc50/snapshots/53532652913251694dd0c260067fc9334b9ab058/paths/1093ad8b89cc6e3ff04d3a5897193f958dab3aa9
  def show
    @commit = @db.repo.commit(params[:commit_id])
    @tree = @db.repo.tree(params[:id])
    render :template => 'snapshots/show'

  end

end
