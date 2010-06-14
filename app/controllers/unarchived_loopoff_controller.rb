class UnarchivedLoopoffController < Loader::DbController
  before_filter :load_unarchived_path
  def load_unarchived_path
    @unarchived_path = @db.unarchived_paths(params[:unarchived_path_id])
    if @unarchived_path.nil?
      render :text => "invalid unarchived path, #{params[:unarchived_path_id]}" and return
    end
  end

  def show
    @collection = @unarchived_path    
    render :partial => 'loopoff_table/show', :layout => true
  end
  
  def export_selected_rows    
    @rows = params[:rows]
    raise "must be array" unless @rows.kind_of? Array
    @rows.map! {|x| x.to_i}

    @export_dir = File.join(@db.path,params[:export_dir].blank? ? @unarchived_path.export_path : params[:export_dir])
    make_export_dir_if_needed
    
    @lt_rows = @unarchived_path.rows.values_at(*@rows)
    @lt_rows.each do |lt_row|
      lt_row.cells.each do |cell|
        next if cell.nil?
        File.open(File.join(@export_dir,cell.basename),'w') do |target|
          target.print cell.data # NOT puts (adds a \n char to the binary)
        end
      end
    end

    

    # SECURITY: UNSANITIZED params[:@export_dir]    
    
    #FileUtils.cp_r(@the_file_paths,@export_dir)
    respond_to do |format|
      format.json { render :json =>{:status => :success,:files => @the_file_paths,:export_path => @export_dir}} 
    end
  end
end

  def make_export_dir_if_needed    
    if !File.directory?(@export_dir)
      if File.exists?(@export_dir)
        render :status => 500, :text => "INVALID export dir #{@export_dir}, a non-directory exists there"
      else
        FileUtils.mkdir(@export_dir)
      end     
    end    
  end
