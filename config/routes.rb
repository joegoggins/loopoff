ActionController::Routing::Routes.draw do |map|
  # # :index db/ => A list of all loop off project dirs with links
  # # :show db/rc50 => links to db/rc50/archive, db/rc50/archive/loopoff, db/rc50/unarchived
  # #
  map.resources :dbs, :as => 'db', :only => [:index,:show] do |db|
    # :loopoff   db/rc50/archive/loopoff => THE MOST IMPORTANT PAGE IN THE ENTIRE APP, the uber loopoff table
    #            containing all loops
    db.resource :blobs, :as => 'archive', :only => :none do |repo_file|
      repo_file.resource :loopoff, :only => :show, :controller => 'archive_loopoff'
      # :cells   db/rc50/archive/cells/0,1 => serves up the binary audio data associated with row 0 column 1...
      #
      repo_file.resources :cells, :only => :show, :controller => 'archive_blob_cell'
    end
    # :index      db/rc50/unarchived => A list of all non repo dir paths in loop_db/rc50/* that contain .WAV files
    #            with links to their loopoff page, something like
    #            <rel_dir_name><number_of_files><link to table>
    #
    # :loopoff   db/rc50/unarchived/loopoff/import/20090529 => A loopoff table with the contents of the directory
    db.resources :unarchived_paths, :as => 'unarchived', 
      :controller => 'unarchived_paths',:only => [:index] do |unarchived_path|
      unarchived_path.resource :loopoff, 
        :only => :show, 
        :member => {
          :export_selected_rows => :get
        },
        :controller => 'unarchived_loopoff'
      unarchived_path.resources :cells, :only => :show, :controller => 'unarchived_path_cell'
    end
    # :index     db/rc50/commits => list view of all commits in the repo like
    #            <date_committed><72 files changed, 31 insertions(+), 0 deletions(-)>
    #            each line links to a commit detail page db/rc50/commits/<sha>/
    # :show      db/rc50/commits/b8491d65 => Links to available subpathes within the checkout (any dir with loopoff-able files aka .WAVs)
    #           plus committ id and commit time and message
    # :loopoff  db/rc50/snapshots/b8491d65/paths/./loopoff => a loopoff table with the files in this commit
    #           if sub directories in this
    db.resources :commits, :as => 'snapshots', :only => [:index, :show], :controller => 'snapshots' do |commit|
      commit.resources :paths,  :only => :show, :controller => 'snapshot_commit_path' do |path|
        path.resource :loopoff, :only => :show, 
          :member => {
            :add_selected_rows_to_playlist => :get
          },
        :controller => 'snapshot_loopoff'
        path.resources :cells, :only => :show, :controller => 'snapshot_commit_path_cell'
      end
    end
  end
  
  # :show => the loopoff table
  #
  map.resources :playlists,
    :member => {
      :delete_row => :get,
      :export_all_files => :get
    } do |playlist|
    playlist.resource :loopoff, :only => :show, :controller => 'playlist_loopoff'
    playlist.resources :cells, :only => :show, :controller => 'playlist_cells' # serves up the binary
  end
  
  #
  map.root :controller => 'main'
    
  
  # CRUSTY CODE TO BE DELETED
  map.resources :directories, 
    :member => {
      :v2 => :get,
      :export_page_of => :get,
      :process_export_page_of => :post,
      :export_selected_rows => :get,
      :v2_export_selected_rows => :get
      
      } do |directory|
    directory.resources :cells, :only => :show # serves the .wav files up
  end

end
