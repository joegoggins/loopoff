class PlaylistCellsController < ApplicationController
  def show
    @pl_cell = PlaylistCell.find(params[:id])    
    @blob = @pl_cell.blob
    send_data @blob.data, :type => "audio/wav", :filename => @blob.id + '.wav'
  end
end
