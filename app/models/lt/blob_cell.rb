class Lt::BlobCell < Lt::Cell
  def aggregation_string(method_to_call=:name_prefix)
    send(method_to_call)
  end
  
  def name_prefix
    self.name.split('_').first
  end
  
  def basename
    "TODO"
  end
  alias_method :to_param, :basename
  
  
  def data
    "TODO"
  end
end