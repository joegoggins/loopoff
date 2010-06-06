class DbsController < ApplicationController
  def index
    @dbs = Db.all
  end

  def show
    @db = Db.all.detect {|x| x.name == params[:id]}
    if @db.nil?
      render :text => "invalid db, #{params[:id]}" and return
    end
  end
end
