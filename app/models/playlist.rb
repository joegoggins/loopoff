class Playlist < ActiveRecord::Base
  has_many :rows, :class_name => "PlaylistRow", :order => "position",:dependent => :delete_all
end
