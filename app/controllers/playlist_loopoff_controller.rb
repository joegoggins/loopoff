class PlaylistLoopoffController < ApplicationController
  def show
    @playlist = Playlist.find(params[:playlist_id])
  end
end
