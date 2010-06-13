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
    # class T1Controller < ApplicationController
    #   before_filter :load_shit
    #   def load_shit
    #     @repo = Repo.first
    #     @grit_repo = Grit::Repo.new(@repo.path)
    #     @blobs = @grit_repo.tree.blobs
    #   end
    # 
    #   def index
    # 
    #   end
    # 
    #   def data
    #     @blob = @blobs.find {|x| x.id == params[:id].gsub(/\.WAV/,'')}
    #     send_data @blob.data, :type => @blob.mime_type, :filename => @blob.name
    #   end
    # end
    # ~                                                                                                                               
    # ~                                                                                                                               
    # ~
    # --- !map:HashWithIndifferentAccess 
    # commit_id: ada3e0ddec82bbc86a971329d978026045bce0d4
    # path_id: "-"
    # action: show
    # id: "6,2"
    # controller: snapshot_commit_path_cell
    # db_id: rc50
  end
  

  # def show
  #     if params[:path_id] == '-'
  #       # This is to avoid
  #       # A copy of Mixins::GritTreeExtensions has been removed from the module tree but is still active
  #       # while in development
  #       Grit::Tree.send(:include, Mixins::GritTreeExtensions)
  #       @collection = @commit.tree
  #       render :template => 'loopoff_table/show'
  #     else
  #       render :text => "sorry bro, only implemented for - aka the \".\" path" and return
  #     end        
  #   end
  #   
end
