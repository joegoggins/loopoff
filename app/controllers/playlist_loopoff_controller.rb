class PlaylistLoopoffController < ApplicationController
  before_filter :load_playlist
  def load_playlist
    @playlist = Playlist.find(params[:playlist_id])
  end
  
  def show    
    @collection = @playlist
  end
  
  def export_files
    debugger
  end
end
