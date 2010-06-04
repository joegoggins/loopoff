desc "go"
task :go => :environment do
  `rake db:drop`
  `rake db:create`
  `rake db:migrate`
  `rake db:fixtures:load`
  puts "boomb mutha fucka"
end