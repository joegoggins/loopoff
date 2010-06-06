class Loader::DbController < ApplicationController
  before_filter :load_db
  def load_db
    @db = Db.all.detect {|x| x.name == params[:db_id]}
    if @db.nil?
      render :text => "invalid db, #{params[:db_id]}" and return
    end
  end
end
