class UnarchivedLoopoffController < Loader::DbController
  before_filter :load_unarchived_path
  def load_unarchived_path
    @unarchived_path = @db.unarchived_paths(params[:unarchived_path_id])
    if @unarchived_path.nil?
      render :text => "invalid unarchived path, #{params[:unarchived_path_id]}" and return
    end
    prefix = "cd #{@unarchived_path.path} && "
    init_command = "#{prefix} git init"
    add_command = "#{prefix} git add *"
    commit_command = "#{prefix} git commit -a -m  \"#{@unarchived_path.name} temp repo\""
    
    begin
      @unarchived_path.repo
    rescue Grit::InvalidGitRepositoryError => e
      render :text => "No .git dir, do this: <pre>#{init_command}</pre>" and return
    end
    if @unarchived_path.repo.commits.empty?
      render :text => "No commits, do this <pre>#{add_command}\n\n#{commit_command}</pre>" and return
    end
  end

  def show
    @table = @unarchived_path.table
  end
end
