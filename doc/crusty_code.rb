
# self.trees.each do |t|
#   if t.contains_loopoff_files?
#     @all_loopoff_child_trees << t
#   end
#   t.trees.each do |t2|
#     if t.contains_loopoff_files?
#       @all_loopoff_child_trees << t
#     end
#     
#     t2.trees.each do |t3|  
#       if t.contains_loopoff_files?
#         @all_loopoff_child_trees << t
#       end
#       # ...
#     end
#   end
# end

#TODO, contineu here
# @unarchived_path.my_aggregated_files.each_with_index do |agg_tuple,row_index|
#       next unless @rows.include?(row_index)
#       agg_tuple.last.each_with_index do |my_file,col_index|
#         if @unarchived_path.cell(row_index,col_index).nil?
#         else
#           @the_file_paths << @unarchived_path.cell(row_index,col_index).name
#         end       
#      end
#     end

b.instance_eval(<<-EOS,__FILE__,__LINE__)
  def name
    "#{b.name}"
  end
  
  def size
    #{b.size}
  end
  
  def sha
    "#{b.id}"
  end
  
  def is_identical
    false
  end
EOS
@cells << b


# def new_blob_ids
#   self.distinct_blob_ids - self.db.repo.distinct_blobs.map(&:id)
# end
# 
# # FIX: p = Db[:rc50].unarchived_paths(/0529/)[0]
# # p.distinct_blobs
# # => ["76c62a5d3ef0e37802c3632a15219e580eab405b", "4ce831386425818744af9864778ec0c37d339555", "8c9906cec4557bb7cb90a65ade29a9e0bf6fddea", "1610294c33bd526fb236d9917bb57c74d7207f2c", "1175d36089d079fd49c18c808e3d138d387cba4a", "5681bc6e4081add10cb817b06e062586ffe54a4a", "8bc91277112d56eb6874caf3081387ad2e647fd5", "73d90ed25e75c123f50e4a272a4b2d3c87773347", "a5fe15a204c59c4a2f46f5c1c614a64f2a980e9c", "1e45a3b2bfb8c43d80cd656781d920cae74e8bc2", "56443ed770a6f480f9ffd157036deda5ec6b9306", "8417d133f1a2b12f4df345c8f007188c1c0104ca", "1d29f62712c2ba72702c497d12c2e574e68a7ee3", "feaeb9c3aad896a74be472118c5a1c6d6ad5e436", "56ceabd8d37a79b1f72acb013058508a662cdc0a"]
# def new_blobs
#   #self.repo.tree.blobs.select {|x| self.new_blob_ids.include?(x.id)}
#   #Grit::GitRuby::Internal::LooseStorage.calculate_sha(File.read(f),'blob') instead
# end
# 
# def identical_blobs
#   self.repo.tree.blobs.select {|x| self.idential_blob_ids.include?(x.id)}
# end
# 
# def idential_blob_ids
#   self.distinct_blob_ids & self.db.repo.distinct_blobs.map(&:id)
# end

# Requires you to manually create the repo for now, Grit and Gash
# were being dumb, raises
#   Grit::InvalidGitRepositoryError => e

# # WARNING DUPLICATION: from repo.rb
# def distinct_blobs
#   if @distinct_blobs.blank?
#     @distinct_blobs = []
#     self.loopoff_files.each do |f|
#       @distinct_blobs << Grit::GitRuby::Internal::LooseStorage.calculate_sha(File.read(f),'blob')
#     end
#   end
#   @distinct_blobs
#   # if @distinct_blobs.blank?
#   #   distinct_blob_ids = []
#   #   @distinct_blobs = []
#   #   self.repo.commits.each do |c|
#   #     c.tree.blobs.each do |b|
#   #       unless distinct_blob_ids.include?(b.id)            
#   #         @distinct_blobs << b
#   #         distinct_blob_ids << b.id
#   #       end
#   #     end
#   #   end      
#   # end
#   # @distinct_blobs
# end
# 
# def distinct_blob_ids
#   self.distinct_blobs.map(&:id)
# end


def table
  #    Db.aggregated_blobs(self.distinct_blobs)
  #    c1
  #     001_1
  #     001_2
  #     001_3
  #    c2
  #     001_2
  #    c3
  #     001_1
  #     002_2.WAV
  #     002_3.WAV
  #
  # @table = Lt::Table.new
  # r = Lt::Row.new('001')
  # r.cells << Lt::Cell.new(0,0,"001_1.WAV")
  # r.cells << Lt::Cell.new(0,1,"001_2.WAV")
  # r.cells << Lt::Cell.new(0,2,"001_3.WAV")
  # @table.rows << r
  # 
  # r = Lt::Row.new('001')
  # r.cells << Lt::Cell.new(1,0,"001_2.WAV")
  # @table.rows << r
  # 
  # r = Lt::Row.new('001')
  # r.cells << Lt::Cell.new(1,0,"001_1.WAV")
  # @table.rows << r
  # r = Lt::Row.new('002')
  # r.cells << Lt::Cell.new(2,0,"002_2.WAV")
  # r.cells << Lt::Cell.new(2,1,"002_3.WAV")
  # @table.rows << r
  @table = Lt::Table.new(self, self.relative_path)
  self.repo.commits.each_with_index do |c,commit_index|
    @row = Lt::Row.new(@table)
    c.tree.blobs.group_by {|b| b.name.split('_').first}.each_with_index do |tuple,blob_index|
      @row.name = tuple.first
      #["001", [#<Grit::Blob "48b4a7f76b059fe8ec04389ff90ca303b6180265">, #<Grit::Blob "3135902f33f339b671e9d2604a3c90f12280409b">, #<Grit::Blob "bc22f5ca84204a9b53ad3f14586fad23a72ed6d4">]]        tuple
      tuple.last.each_with_index do |blob,cell_index|
        @row.cells << Lt::Cell.new(@row, blob_index,cell_index,blob.id)
      end
      @table.rows << @row.clone
      #prefix, middle, extension = b.name.match(/(.+)_(.+)\.(.+)/).to_a[1..-1] 
    end 
  end
  return @table
end