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
    
    if params[:path_id] == '-'
      @collection = @commit.tree
    else
      render :text => "sorry bro, only implemented for - aka the \".\" path" and return
    end
  end

  def show
    render :template => 'loopoff_table/show'    
    # do nothing, already loaded via before_filter    
  end


  # def export_selected_rows    
  #    @rows = params[:rows]
  #    raise "must be array" unless @rows.kind_of? Array
  #    @rows.map! {|x| x.to_i}
  # 
  #    @export_dir = File.join(@db.path,params[:export_dir].blank? ? @unarchived_path.export_path : params[:export_dir])
  #    make_export_dir_if_needed
  # 
     # @lt_rows = @unarchived_path.rows.values_at(*@rows)
     # @lt_rows.each do |lt_row|
     #   lt_row.cells.each do |cell|
     #     next if cell.nil?
     #     File.open(File.join(@export_dir,cell.basename),'w') do |target|
     #       target.print cell.data # NOT puts (adds a \n char to the binary)
     #     end
     #   end
     # end
  # 

  def add_selected_rows_to_playlist
    @rows = params[:rows]
    raise "must be array" unless @rows.kind_of? Array
    @rows.map! {|x| x.to_i}
    
    @playlist = Playlist.find(params[:playlist_export_id])
    @lt_rows = @collection.rows.values_at(*@rows)
    @lt_rows.each do |lt_row|
      pl_row = @playlist.rows.create(:aggregation_string => lt_row.name,
        :commit_id => @commit.id,
        :loopoff_db => @db.to_param
      )      
      lt_row.cells.each do |cell|
        next if cell.nil?        
        pl_row.cells.create(:blob_id => cell.id,
          :commit_id => @commit.id,
          :loopoff_db => @db.to_param,
          :name =>cell.name
        )
      end
    end

    
    
    
    render :text => 'hi' and return
  end
end
