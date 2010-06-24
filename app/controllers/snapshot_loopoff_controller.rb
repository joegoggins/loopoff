class SnapshotLoopoffController < Loader::DbController
  before_filter :load_commit
  def load_commit    
    # This is to avoid
    # A copy of Mixins::GritTreeExtensions has been removed from the module tree but is still active
    # while in development
    Grit::Tree.send(:include, Mixins::GritTreeExtensions)
    
    @commit = @db.repo.commit(params[:commit_id])
    if @commit.nil?
      render :text => "invalid commit id, #{params[:commit]}" and return
    end
    
    @collection = @db.repo.tree(params[:path_id])
  end

  def show
    render :partial => 'loopoff_table/show', :layout => true
    # do nothing, already loaded via before_filter    
  end

  # TODO: DUPLICATION CLEANUP
  def add_selected_rows_to_playlist
    @rows = params[:rows]
    raise "must be array" unless @rows.kind_of? Array
    @rows.map! {|x| x.to_i}
        
    @lt_rows = @collection.rows.values_at(*@rows)
    @lt_rows.each do |lt_row|
      pl_row = @export_playlist.rows.find_or_create_by_aggregation_string_and_commit_id_and_loopoff_db(
        lt_row.name,@commit.id, @db.to_param
      )      
      lt_row.cells.each do |cell|
        next if cell.nil?        
        pl_row.cells.find_or_create_by_blob_id_and_commit_id_and_loopoff_db_and_name(
         cell.sha, @commit.id, @db.to_param,cell.name
        )
      end
    end
    render :text => 'hi' and return
  end  
end
