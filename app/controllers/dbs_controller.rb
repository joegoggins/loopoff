class DbsController < ApplicationController
  def index
    @dbs = ['rc50']
  end

  def show
    @db = "rc50"
  end

end
