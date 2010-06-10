class UnarchivedLoopoffController < Loader::DbController
  before_filter :load_unarchived_path
  def load_unarchived_path
    @unarchived_path = @db.unarchived_paths(params[:unarchived_path_id])
    if @unarchived_path.nil?
      render :text => "invalid unarchived path, #{params[:unarchived_path_id]}" and return
    end
  end

  def show
    @my_aggregated_files = @unarchived_path.my_aggregated_files
  end
  
  def export_selected_rows    
    @rows = params[:rows]
    raise "must be array" unless @rows.kind_of? Array
    @rows.map! {|x| x.to_i}
    @the_file_paths = []
    @unarchived_path.my_aggregated_files.each_with_index do |agg_tuple,row_index|
      next unless @rows.include?(row_index)
    	agg_tuple.last.each_with_index do |my_file,col_index|
    	  if @unarchived_path.cell(row_index,col_index).nil?
        else
          @the_file_paths << @unarchived_path.cell(row_index,col_index).name
        end			  
     end
    end

    # SECURITY: UNSANITIZED params[:export_dir]    
    export_dir = File.join(@db.path,params[:export_dir].blank? ? @unarchived_path.export_path : params[:export_dir])
    if !File.directory?(export_dir)
      if File.exists?(export_dir)
        render :status => 500, :text => "INVALID export dir #{export_dir}, a non-directory exists there"
      else
        FileUtils.mkdir(export_dir)
      end     
    end
    FileUtils.cp_r(@the_file_paths,export_dir)
    respond_to do |format|
      format.json { render :json =>{:status => :success,:files => @the_file_paths,:export_path => export_dir}} 
    end
  end
end
