class CellsController < ApplicationController
  before_filter :load_directory
  def show

    @row, @column = params[:id].split('_')
    if @row.blank? || @column.blank?
      render :status => 404, :text => 'Invalid cell URL, must be sep by comma like 0,0 or 0,2 0min 2max yo' and return
    end
    
    @cell = @directory.cell(@row,@column)
    if @cell.nil?
      render :status => 404, :text => "Why are you askin for a file cell that doesnt exist for this row" and return
    end
     respond_to do |format|
        format.wav {
          send_data File.read(@directory.file_path_to_cell(@row,@column)),
          :type => 'audio/wav', 
          :filename => "#{@directory.cell(@row,@column)}.WAV"
        }
      end    
  end
  def load_directory
    begin
      @directory = Directory.find(params[:directory_id])
    rescue ActiveRecord::RecordNotFound => e
      render :status => 404, :text => "Sorry bro that dir doesnt exist"
    end
  end
  
end
