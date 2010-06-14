class PlaylistsController < ApplicationController
  before_filter :load_playlist_and_db_hack, :only => [:delete_row, :export_all_files]
  
  def load_playlist_and_db_hack
    @db = Db[:rc50]
    @playlist = Playlist.find(params[:id])    
  end  
  
  def delete_row
    begin
      @row_index = params[:row_index].to_i
    rescue
      render :text => "ERROR params[:row_index] not specified",:status => 500 and return
    end

    @playlist_row = @playlist.rows[@row_index]
    if @playlist_row.destroy
      respond_to do |format|
        format.json { render :json =>{:status => :success}} 
      end
    else
      render :text => "ERROR could not destroy",:status => 500 and return
    end
  end
  
  def export_all_files
    to_copy = []
    
    # TODO: make the export_dir NOT in the rc50 sub-dir
    # to allow for playlists that span mutiple devices/loopoff dbs
    # now I'm assuming it's a rc50 export
    # this code below puts things where they should be eventually
    #@export_dir = File.join(RAILS_ROOT,'loop_db','playlist_export',@playlist.export_path)
    
    @export_dir = File.join(@db.path,'playlist_export',@playlist.export_path)
    @playlist.rows.each_with_index do |row,rindex|
      row.cells.each_with_index do |cell,cindex|
        f_name_prefix=(rindex+1).to_s.rjust(3,"0") # produces strings like 001 021 099, etc        
        target_name = f_name_prefix + "_" + (cindex + 1).to_s + ".WAV"
        full_target_path = File.join(@export_dir,target_name)
        source_blob = cell.blob
        to_copy << [source_blob, full_target_path]        
      end
    end
    make_export_dir_if_needed
    to_copy.each do |tuple|
      File.open(tuple.last,'w') do |target|
        target.print tuple.first.data # NOT puts (adds a \n char to the binary)
      end
    end
    render :text => 'hi exporter guy' and return
  end
  
  # GET /playlists
  # GET /playlists.xml
  def index
    @playlists = Playlist.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @playlists }
    end
  end

  # GET /playlists/1
  # GET /playlists/1.xml
  def show
    @playlist = Playlist.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @playlist }
    end
  end

  # GET /playlists/new
  # GET /playlists/new.xml
  def new
    @playlist = Playlist.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @playlist }
    end
  end

  # GET /playlists/1/edit
  def edit
    @playlist = Playlist.find(params[:id])
  end

  # POST /playlists
  # POST /playlists.xml
  def create
    @playlist = Playlist.new(params[:playlist])

    respond_to do |format|
      if @playlist.save
        flash[:notice] = 'Playlist was successfully created.'
        format.html { redirect_to(@playlist) }
        format.xml  { render :xml => @playlist, :status => :created, :location => @playlist }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @playlist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /playlists/1
  # PUT /playlists/1.xml
  def update
    @playlist = Playlist.find(params[:id])

    respond_to do |format|
      if @playlist.update_attributes(params[:playlist])
        flash[:notice] = 'Playlist was successfully updated.'
        format.html { redirect_to(@playlist) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @playlist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /playlists/1
  # DELETE /playlists/1.xml
  def destroy
    @playlist = Playlist.find(params[:id])
    @playlist.destroy

    respond_to do |format|
      format.html { redirect_to(playlists_url) }
      format.xml  { head :ok }
    end
  end
end
