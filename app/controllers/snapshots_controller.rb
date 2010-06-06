class SnapshotsController < Loader::DbController
  def index    
    @commits = @db.repo.commits
  end

  def show
    @commit = @db.repo.commit(params[:id])
    @diff_stats = @commit.stats.to_diffstat
    @commit_paths = [] 
    # TODO: check for loopable files in each
    if @commit.tree.trees.empty?
      @commit_paths << [".","-"] 
    else
      @commit_paths << [".","-"] 
      @commit.tree.trees.each do |tree|
        @commit_paths << [tree.name,tree.name]
      end
    end
  end
end
