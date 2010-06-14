class Playlist < ActiveRecord::Base
  has_many :rows, :class_name => "PlaylistRow", :order => "position",:dependent => :delete_all
  has_many :cells, :through => :rows
  
  # DUPLICATED
  def cell(x,y)
    if self.rows[x.to_i].nil?
      nil
    else
      self.rows[x.to_i].cells[y.to_i]
    end
  end
  
end
