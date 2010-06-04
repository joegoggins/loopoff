# Description:
#     Explain the generator
# 
# Example:
#     ./script/generate static_html <dir_id>
require 'rails_generator'
class StaticHtmlGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      #require 'action_controller/integration'
      m.directory "public/export"

      @directory = Directory.find(self.name)
      @assets_dir = "public/export/#{@directory.slug}_files"      
      m.directory @assets_dir
      m.directory "#{@assets_dir}/javascripts"
      m.directory "#{@assets_dir}/stylesheets"
      m.directory "#{@assets_dir}/images/icons"
      m.directory "#{@assets_dir}/audio"
      require 'fileutils'
      #FileUtils.cp_r("public/images/icons","#{@assets_dir}/images/icons")
      #FileUtils.cp_r(@directory.path,"#{@assets_dir}/audio")
      # m.directory "lib"
      # m.template 'README', "README"
    end
  end
end
