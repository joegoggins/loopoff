class UnarchivedPathCellController < Loader::DbController
  def show
    @unarchived_path = @db.unarchived_paths(params[:unarchived_path_id])

    @row, @column = params[:id].split(',')
    if @row.blank? || @column.blank?
      render :status => 404, :text => 'Invalid cell URL, must be sep by comma like 0,0 or 0,2 0min 2max yo' and return
    end

    @cell = @unarchived_path.cell(@row,@column)
    if @cell.nil?
      render :status => 404, :text => "Why are you askin for a file cell that doesnt exist for this row" and return
    end

    respond_to do |format|
      format.wav {
        send_data @unarchived_path.cell(@row,@column).data,
        :type => 'audio/wav', 
        :filename => "#{@unarchived_path.cell(@row,@column).basename}"
      }
    end    
  end
end
