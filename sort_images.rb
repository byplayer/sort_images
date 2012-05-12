ENV['BUNDLE_GEMFILE'] = File.join(File.dirname(__FILE__), 'GemFile')
require "bundler"
Bundler.setup(:default)

require 'exifr'
require 'optparse'
require 'fileutils'
require 'digest/md5'

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
      File.join(out_dir, photo_date.strftime('%Y%m%d'))
    FileUtils::mkdir_p(mv_dir) unless File.exists?(mv_dir)

    new_name = photo_date.strftime('%H%M%S_') + File::basename(f)
    new_path = File.join(mv_dir, new_name)
    FileUtils.cp(f, new_path)

    # verify
    unless Digest::MD5.file(new_path).hexdigest == Digest::MD5.file(f).hexdigest
      puts Digest::MD5.hexdigest(new_path)
      puts Digest::MD5.hexdigest(f)
      raise "#{f} move verify error"
    end
    FileUtils.rm(f)
  else
    puts "no photo date: #{f}"
  end
end

