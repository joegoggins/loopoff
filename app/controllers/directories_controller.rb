require 'fileutils'    
require 'ostruct'
class DirectoriesController < ApplicationController
  before_filter :load_all_directories
  
  def v2
    @db = Db[:rc50]
    @unarchived_path = @db.unarchived_paths(params[:id])
    @my_aggregated_files = @unarchived_path.my_aggregated_files
#    debugger
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @directory }
    end
    
  end
  def load_all_directories
    @directories = Directory.all.sort_by(&:slug)
  end
  
  def export_selected_rows
    @directory = Directory.find(params[:id])
    @rows = params[:rows]
    @export_dir = Directory.find(params[:export_dir]);
    
    raise "must be array" unless @rows.kind_of? Array
    @rows.map! {|x| x.to_i}
    @the_file_paths = []
		@directory.aggregated_files.each_with_index do |agg_tuple,row_index|
		  next unless @rows.include?(row_index)
			agg_tuple.last.each_with_index do |base_file_name,col_index|
			  if @directory.cell(row_index,col_index).nil?
		    else
		      @the_file_paths << @directory.file_path_to_cell(row_index,col_index)
	      end			  
      end
    end
    if !File.directory?(@export_dir.path)
      begin
        FileUtils.rm_rf @export_dir.path
      rescue
      end
      FileUtils.mkdir(@export_dir.path)
    end
    FileUtils.cp_r(@the_file_paths,@export_dir.path)
    respond_to do |format|
      format.json { render :json =>{:status => :success,:files => @the_file_paths,:export_path => @export_dir.path}} 
    end
  end
  def export_page_of
    @directory = Directory.find(params[:id])
    @export_mode = true
    build_export_directory
    render :action => 'show'
  end

=begin
public/export
  <dir_slug>.html
  <dir_slug>_files
    javascripts/all.js
    stylesheets/all.js
    images/icons
      *.png
    audio
      078_1.WAV
      *...
    licence.html
    about.html
=end
  def base_export_dir
    "#{@directory.slug}_files"
  end
  
  def build_export_directory
    @export_dir = OpenStruct.new(:path =>"#{RAILS_ROOT}/public/export")
        
    if File.directory?(@export_dir.path)
      FileUtils.rm_rf @export_dir.path
    end
    FileUtils.mkdir @export_dir.path
    
    
    @index_path = @export_dir.path + '/index.html'
    @assets_path = "#{@export_dir.path}/#{@directory.slug}_files"
    
    
    File.open(@index_path,'w') do |f|
      f.puts render_to_string :action => 'show'      
    end
    File.open("#{@assets_path}/all.css",'w') do |f|
      f.puts concatenated_global_css_string
    end
    File.open("#{@assets_path}/all.js",'w') do |f|
      f.puts concatenated_global_js_string
    end
    
    FileUtils.mkdir "#{@assets_path}/images"
    FileUtils.cp_r('public/images/icons',"#{@assets_path}/images")
    FileUtils.cp_r(@directory.path,"#{@assets_dir}/audio")
  end
  # GET /directories
  # GET /directories.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @directories }
    end
  end

  # GET /directories/1
  # GET /directories/1.xml
  def show
    @directory = Directory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @directory }
    end
  end

  # GET /directories/new
  # GET /directories/new.xml
  def new
    @directory = Directory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @directory }
    end
  end

  # GET /directories/1/edit
  def edit
    @directory = Directory.find(params[:id])
  end

  # POST /directories
  # POST /directories.xml
  def create
    @directory = Directory.new(params[:directory])

    respond_to do |format|
      if @directory.save
        flash[:notice] = 'Directory was successfully created.'
        format.html { redirect_to(directories_path) }
        format.xml  { render :xml => @directory, :status => :created, :location => @directory }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @directory.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /directories/1
  # PUT /directories/1.xml
  def update
    @directory = Directory.find(params[:id])

    respond_to do |format|
      if @directory.update_attributes(params[:directory])
        flash[:notice] = 'Directory was successfully updated.'
        format.html { redirect_to(@directory) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @directory.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /directories/1
  # DELETE /directories/1.xml
  def destroy
    @directory = Directory.find(params[:id])
    @directory.destroy

    respond_to do |format|
      format.html { redirect_to(directories_url) }
      format.xml  { head :ok }
    end
  end
end
