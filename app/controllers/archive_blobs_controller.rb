class ArchiveBlobsController < Loader::DbController
  def show
    @blob = @db.repo.blob(params[:id])
    send_data @blob.data, :type => "audio/wav", :filename => @blob.id + '.wav'
  end

  def loopoff
    # This is to avoid
    # A copy of Mixins::GritTreeExtensions has been removed from the module tree but is still active
    # while in development
    Grit::Tree.send(:include, Mixins::GritTreeExtensions)
    @collection = @db.repo 

    render :partial => 'loopoff_table/show', :layout => true
  end

  def index
  end

end
