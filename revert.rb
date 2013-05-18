ENV['BUNDLE_GEMFILE'] = File.join(File.dirname(__FILE__), 'GemFile')
require "bundler"
Bundler.setup(:default)

require 'exifr'
require 'optparse'
require 'fileutils'
require 'digest/md5'

opt = OptionParser.new

in_dir = nil
opt.on('-i IN_DIR'){|v| in_dir = v}

def usage(opt)
  puts opt.help
end

opt.parse!(ARGV)

if(!in_dir)
  usage(opt)
  exit(1)
end

Dir.glob(File.join(in_dir, '*.jpg')) do |f|
  # "./new/20130103/164908_P1010057.JPG"

  new_path = File.dirname(f)
  basename = File.basename(f)

  # puts basename

  # if basename =~ /^[0-9]{6}_(.*\.jpg)$/
  if basename =~ /([0-9]{6}_)(.*\.jpg)/i
    new_path = File.join(new_path, $2)
    puts "move to #{new_path}"
    FileUtils.cp(f, new_path)
    FileUtils.rm(f)
  else
    puts "sikip #{f}"
  end
end

