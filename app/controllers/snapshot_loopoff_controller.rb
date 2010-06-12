class SnapshotLoopoffController < Loader::DbController
  before_filter :load_commit
  def load_commit    
    @commit = @db.repo.commit(params[:commit_id])
    if @commit.nil?
      render :text => "invalid commit id, #{params[:commit]}" and return
    end
  end

  def show
    if params[:path_id] == '-'
      
      @collection = @commit.tree
      render :template => 'loopoff_table/show'
    else
      render :text => "sorry bro, only implemented for - aka the \".\" path" and return
    end        
  end

end
