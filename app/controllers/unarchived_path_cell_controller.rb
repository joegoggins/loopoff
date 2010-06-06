class UnarchivedPathCellController < ApplicationController
  def show
    render :inline => '<%= debug params %>'
  end
end
