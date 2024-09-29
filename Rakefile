require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[test]

# Build d4bindings

namespace :d4 do
  desc 'Build d4binding'
  task :build do
    Dir.chdir('d4-format') do
      sh 'cargo build --release --package=d4binding'
    end
    FileUtils.mkdir_p('vendor')
    require 'ffi'
    sh "cp d4-format/target/release/libd4binding.#{FFI::Platform::LIBSUFFIX} vendor"
  end

  desc 'Clean d4binding'
  task :clean do
    Dir.chdir('d4-format/d4binding') do
      sh 'cargo clean'
    end
  end
end
