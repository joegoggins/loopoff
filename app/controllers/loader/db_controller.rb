class Loader::DbController < ApplicationController
  before_filter :load_db
  def load_db
    @db = 'rc50'
  end
end
