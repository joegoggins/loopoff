class SnapshotCommitPathCellController < Loader::DbController
  before_filter :load_commit
  def load_commit    
    @commit = @db.repo.commit(params[:commit_id])
    if @commit.nil?
      render :text => "invalid commit id, #{params[:commit]}" and return
    end
  end
  
  def show
    if params[:path_id] = '-'
      @blob = @db.repo.blob(params[:id])
    else
      # not sure...
    end
    #debugger
    send_data @blob.data, :type => "audio/wav", :filename => @blob.id + '.wav'
  end  
end
