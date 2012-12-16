Gem::Specification.new do |s|
  s.name        = 'bayesian_average'
  s.version     = '0.0.1'
  s.date        = '2012-12-13'
  s.summary     = "A simple way to add Bayesian averages to you ActiveModel classes"
  s.description = "A simple way to add Bayesian averages to you ActiveModel classes"
  s.authors     = ["Ryder Moody"]
  s.email       = 'rydthemoodster@gmail.com'
  s.files       = ["lib/bayesian_average.rb"]
  s.add_dependency('mongoid', '>= 3.0.0')
  s.add_dependency('activesupport', '>= 3.2.0')
  s.add_development_dependency 'rspec', '2.12.0'
end
