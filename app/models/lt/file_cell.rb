class Lt::FileCell < Lt::Cell
  def basename
    File.basename(self.name)
  end
  alias_method :to_param, :basename


  def data
    File.read(self.name)
  end
end