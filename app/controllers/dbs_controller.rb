class DbsController < Loader::DbController
  skip_before_filter :load_db, :only => :index
  def index
    @dbs = Db.all
  end

  def show
  end

end
