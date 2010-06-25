class Lt::BlobCell < Lt::Cell
  def aggregation_string(method_to_call=:name_prefix)
    send(method_to_call)
  end
  
  def name_prefix
    self.name.split('_').first
  end
  
  def basename
    self.name
  end

  def to_param
    self.sha
  end  
end