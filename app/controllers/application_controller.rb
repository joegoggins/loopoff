# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  
  before_filter :load_export_playlist
  def load_export_playlist
    @export_playlist = Playlist.find_or_create_by_title('first_playlist') # HARD CODED
  end
  
  def global_css_files
    ['application','jq_modal']
  end
  helper_method :global_css_files

  def global_js_files
     ['jquery','inspect','jq_modal','loopoff_table']
  end
  helper_method :global_js_files

  def concatenated_global_css_string
    returning '' do |s|
      global_css_files.each do |fn|
        s << File.read("#{RAILS_ROOT}/public/stylesheets/#{fn}.css")
      end
    end
  end

  def concatenated_global_js_string
    returning '' do |s|
      global_js_files.each do |fn|
        s << File.read("#{RAILS_ROOT}/public/javascripts/#{fn}.js")
      end
    end
  end
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def exportable_cell_path(directory,row_index,col_index)
    if @export_mode
      "#{@directory.slug}_files/#{row_index}_#{col_index}.wav"
    else
      directory_cell_path(directory,"#{row_index}_#{col_index}",:format => 'wav')
    end
  end
  helper_method :exportable_cell_path

  def render_stylesheet_link_tags
    if @export_mode
      s = <<-EOS
      <link href="#{@directory.slug}.css" media="screen" rel="stylesheet" type="text/css" />
      EOS
      s
    else
      render_to_string :inline => "<%= stylesheet_link_tag global_css_files %>"
    end
  end
  helper_method :render_stylesheet_link_tags
  
  def render_javascript_include_tags
    if @export_mode
      s = <<-EOS
      <script src="#{@directory.slug}.js" type="text/javascript"></script>
      EOS
      s
    else
      render_to_string :inline => '<%= javascript_include_tag global_js_files %>'
    end
  end
  helper_method :render_javascript_include_tags
  
end
