#!/usr/bin/env ruby


#for example:
#  cat /var/ftp/rails/vogt/public/stylesheets/g_pub.css | grep thoughtless | ruby down_dyn_img.rb

# TODO: have more certainty about the directory the files are saved to


def get_local_path(url)
  path = url.sub(/^http\:\/\/www\.thoughtless\.ca\/dyn_img\/[a-z0-9\-]+\//i, '')
  path.gsub('/', '-')
end

def find_url(str)
  #background-image: url('http://www.thoughtless.ca/dyn_img/9910c180-8ae9-4d88-b551-309c2309c8ed/gradient/direction/top/from/444444/to/777777/size/10.png');
  str.match(/http\:\/\/www\.thoughtless\.ca\/dyn_img\/[a-z0-9\-]+\/.*\.png/i)[0]
end

while !STDIN.eof? do
  url = find_url(STDIN.gets)
  `wget #{url} -O #{get_local_path(url)}`
end


