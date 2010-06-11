class SnapshotLoopoffController < Loader::DbController
  def load_commit
    @commit = @db.repo.commit(params[:id])
    if @commit.nil?
      render :text => "invalid commit id, #{params[:commit]}" and return
    end
  end

  def show
        
  end

end
