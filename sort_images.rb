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
td = nil
opt.on('-i IN_DIR'){|v| in_dir = v}
opt.on('-o OUT_DIR'){|v| out_dir = v}
opt.on('-d [difference in time]'){|v| td = v}

def usage(opt)
  puts opt.help
end

opt.parse!(ARGV)

if(!in_dir || !out_dir)
  usage(opt)
  exit(1)
end

if td
  unless td =~ /^-?[0-9]{1,2}$/
    usage(opt)
    exit(1)
  end
end

Dir.glob(File.join(in_dir, '*.jpg')) do |f|
  photo_date = EXIFR::JPEG.new(f).date_time_original
  if td
    # puts photo_date
    photo_date = photo_date + (td.to_i * 60 * 60)
    # puts photo_date
  end

  if photo_date
    mv_dir =
      File.join(out_dir, photo_date.strftime('%Y%m%d'))
    FileUtils::mkdir_p(mv_dir) unless File.exists?(mv_dir)

    new_name = photo_date.strftime('%H%M%S_') + File::basename(f)
    new_path = File.join(mv_dir, new_name)
    if File.exist?(new_path)
      puts "target exist\n  from: #{f}\n  to#{new_path}"
    else
      FileUtils.cp(f, new_path)

      # verify
      unless Digest::MD5.file(new_path).hexdigest == Digest::MD5.file(f).hexdigest
        puts Digest::MD5.hexdigest(new_path)
        puts Digest::MD5.hexdigest(f)
        raise "#{f} move verify error"
      end
      FileUtils.rm(f)
    end
  else
    puts "no photo date: #{f}"
  end
end

