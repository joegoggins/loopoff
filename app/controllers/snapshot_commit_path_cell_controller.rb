class SnapshotCommitPathCellController < Loader::DbController
  before_filter :load_commit
  def load_commit    
    @commit = @db.repo.commit(params[:commit_id])
    if @commit.nil?
      render :text => "invalid commit id, #{params[:commit]}" and return
    end
  end
  
  def show
    @blob = @db.repo.blob(params[:id])
    send_data @blob.data, :type => "audio/wav", :filename => @blob.id + '.wav'
  end  
end
