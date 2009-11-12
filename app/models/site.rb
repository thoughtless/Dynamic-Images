require 'addressable/uri'
# http://addressable.rubyforge.org/

class Site < ActiveRecord::Base
  belongs_to :user
#  validates_presence_of :user_id, :address
#  validates_format_of :address, :with => /http\:\/\/[0-9a-zA-Z\$\-\_\.\+\!\*\'\(\)\,\%]*\//, :message => 'must start with "http://", end with "/", and otherwise contain only letters, numbers, and the special characters "$-_.+!*''(),". (See <a href="http://www.rfc-editor.org/rfc/rfc1738.txt">http://www.rfc-editor.org/rfc/rfc1738.txt</a>)'
    
  attr_protected :user_id
  
  def validate
    # user_id validation
    begin
      User.find(self.user_id)
    rescue
      errors.add(:user_id, "must reference a valid user")
    end
    
    # address validation
    
    unless self.address.nil? || self.address == ""
    
      begin
        # Parse address
        uri = Addressable::URI.heuristic_parse(self.address, :scheme => 'http')
      
        # if it failed, try adding http:// to the beginning and trying again.
        uri = Addressable::URI.heuristic_parse('http://' + self.address, :scheme => 'http') if uri.scheme.nil? and uri.host.nil?
      rescue Addressable::URI::InvalidURIError
        errors.add(:address, 'could not be parsed. If you are sure it is correct, please contact us and explain the problem.')
      end
      unless uri.nil?
        unless uri.host =~ /^(\*\.){0,1}[0-9a-zA-Z\$\-\_\.\+\!\'\(\)\,\%]+$/
          errors.add(:address, 'can only have letters, numbers, and the special characters "$-_.+!''()," in the host name.')
        end
        unless uri.path =~ /^[0-9a-zA-Z\$\-\_\.\+\!\'\(\)\,\%\/]*$/
          errors.add(:address, 'can only have letters, numbers, and the special characters "$-_.+!''()," in the path.')
        end
        unless Addressable::URI.ip_based_schemes.include?(uri.scheme)
          errors.add(:address, 'must start with be one of ' + Addressable::URI.ip_based_schemes.sort.join(', '))
        end
        unless uri.query.nil?
          errors.add(:address, 'cannot contain a query string. Try removing any "?" characters.')
        end
        unless uri.fragment.nil?
          errors.add(:address, 'cannot contain a fragment. Try removing any "#" characters.')
        end
        uri.path += '/' unless uri.path =~ /\/$/
        uri.password = nil
        uri.user = nil
        uri.port = nil
        uri.fragment = nil
        uri.query = nil
        self.address = uri.normalize.to_s if self.errors.reject{|attr| attr == 'address'}.empty?
      end
    else
      errors.add(:address, 'is missing')
    end
#    raise logger.debug uri.to_hash.to_yaml

  end
  
  def self.find_by_access_key(access_key)
    Site.find_by_sql(
      ["SELECT sites.id, sites.address FROM access_keys INNER JOIN users ON users.id = access_keys.user_id INNER JOIN sites ON sites.user_id = users.id WHERE (access_keys.key = ?)", access_key] )
  end
  
# This version of self.find_by_access_key(access_key) caches to disk. It is not actually faster for small db loads  
#    def self.find_by_access_key(access_key)
#    file = 'tmp/access_keys/' + access_key.gsub(/[^0-9A-Fa-f]/, '_')
#    FileUtils.mkdir_p(File.dirname(file))
#    if FileTest::exist?(file)
#      f = File.new(file)
#      s = YAML.load(f)
#      f.close
#    else
#      s = Site.find_by_sql(
#        ["SELECT sites.id, sites.address 
#          FROM access_keys INNER JOIN users ON users.id = access_keys.user_id INNER JOIN sites ON sites.user_id = users.id 
#          WHERE (access_keys.key = ?)", access_key] )
#      File.open(file, "w+") do |f|
#        f.puts s.to_yaml
#      end
#    end
#    s
#  end

  def validate_http_referer(ref)
    # This expects 'ref' to be a valid (or at least mostly valid) url. It may through an exception if it isn't
    ref_uri = Addressable::URI.heuristic_parse(ref, :scheme => 'http')
    address_uri = address_as_uri
    
    schemes_match?(ref_uri.scheme, address_uri.scheme) && hosts_match?(ref_uri.host, address_uri.host) && paths_match?(ref_uri.path, address_uri.path)
#    schemes_match?(ref_uri.scheme) && hosts_match?(ref_uri.host) && paths_match?(ref_uri.path)
  end

  protected
  
  def address_as_uri
    Addressable::URI.heuristic_parse(self.address, :scheme => 'http')
  end
  
  def paths_match?(ref, add)
    ref = '/' if ref == '' # blank ref is equivalent to /
#    logger.debug "\n\nPaths\n  address: #{add}\n  ref: #{ref}\n\n"
    ref.slice(0,add.size) == add
  end
  
  def hosts_match?(ref, add)
#    logger.debug "\n\nHosts\n  address: #{add}\n  ref: #{ref}\n\n"
    if add =~ /^\*\./
      ref.slice(1-add.size,add.size) == add.slice(1,add.size) || ref == add.slice(2,add.size)
    else
      ref == add
    end
  end
  
  def schemes_match?(ref,add)
#    logger.debug "\n\nSchemes\n  address: #{add}\n  ref: #{ref}\n\n"
    ref == add
  end
  
end
