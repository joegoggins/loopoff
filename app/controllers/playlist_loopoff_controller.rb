class PlaylistLoopoffController < ApplicationController
  def show
    @playlist = Playlist.find(params[:playlist_id])
    @collection = @playlist
    render :template => 'loopoff_table/show'
  end
end
