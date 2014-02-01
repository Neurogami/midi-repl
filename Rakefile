require 'rake/testtask'

begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name     'midi-repl'
  authors  'James Britt / Neurogami'
  email    'james@neurogami.com'
  url      'http://code.neurogami.com'
  depends_on ['unimidi', 'midi-eye']
  description "Provides a REPL for sending arbitray MIDI commands to some device." 
  
  exclude %w{ .git .__ .bnsignore .gitignore }
  gem.need_tar false
}


