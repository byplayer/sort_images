ENV['BUNDLE_GEMFILE'] = File.join(File.dirname(__FILE__), 'GemFile')
require "bundler"
Bundler.setup(:default)

require 'exifr'
require 'optparse'
require 'fileutils'
opt = OptionParser.new

in_dir = nil
out_dir = nil
opt.on('-i IN_DIR'){|v| in_dir = v}
opt.on('-o OUT_DIR'){|v| out_dir = v}

def usage(opt)
  puts opt.help
end

opt.parse!(ARGV)

if(!in_dir || !out_dir)
  usage(opt)
  exit(1)
end

Dir.glob(File.join(in_dir, '*.jpg')) do |f|
  photo_date = EXIFR::JPEG.new(f).date_time_original
  if photo_date
    mv_dir =
      File.join(out_dir, EXIFR::JPEG.new(f).date_time_original.strftime('%Y%m%d'))
    Dir::mkdir(mv_dir) unless File.exists?(mv_dir)
    FileUtils.cp(f, File.join(mv_dir, File::basename(f)))
    FileUtils.rm(f)
  else
    puts "no photo date: #{f}"
  end
end

