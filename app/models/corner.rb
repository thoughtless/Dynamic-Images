require 'RMagick'
include Magick

class Corner < ActiveRecord::Base

  #http://www.whizkidtech.redprince.net/bezier/circle/
  @kappa = 4*(((2.0**(1.0/2.0))-1)/3)

  def self.simple(direction='top-left', c1='#ffffff', c2='#000000', curve=1, size1=50, size2=nil)
  
    c1 = self.clean_color c1
    c2 = self.clean_color c2
  
    direction ||= 'top-left'
    c1 ||= '#ffffff'
    c2 ||= '#000000'
    size1 ||= 50
    size2 ||= size1
    curve ||= 1
    
    if curve < 0
      negative_curve = true
      tmp = c1
      c1 = c2
      c2 = tmp
      tmp = nil
      curve = -1 * curve
    end
    
    #can't process large images
    if size1 > self.max_size || (size2 || 0) > self.max_size
      case
        when size2.nil?; size1 = self.max_size
        when size1 > size2
          ratio = size2.to_f / size1.to_f
          size1 = self.max_size
          size2 = (ratio * size1).ceil
        when size1 < size2
          ratio = size1.to_f / size2.to_f
          size2 = self.max_size
          size1 = (ratio * size2).ceil
        else
          size1, size2 = self.max_size, self.max_size
      end
    end
    
    r = self.simple_corner(direction, c1, c2, curve, size1, size2)
    r.format=('PNG')
    r.compression=(Magick::ZipCompression)
    r.flip!.flop! if negative_curve
#    raise if negative_curve
    r
  end
  
  protected

  def self.simple_corner(direction='top-left', c1='#ffffff', c2='#000000', curve=1, size1=50, size2=nil)
    case direction
      when 'top-left'
       # size2 = size1 #eventually different ratios should be permitted
#        border = 0  #borders won't be used. get rid of this
#raise 'size1' if size1.nil?
#raise 'size2' if size2.nil?
        r = Image.new(size1,size2){|i| i.background_color=c1}
        c = Draw.new
        c.fill(c2)
        c.path("M#{size1},#{size2} L0,#{size2} C0,#{size2 -(@kappa * size2 * curve)} #{size1 - (@kappa * size1 * curve)},0 #{size1},0 z")
                
        c.draw(r)
        
        return r
      when 'bottom-left'
        return self.simple_corner('top-left', c1, c2, curve, size1, size2).flip
      when 'top-right'
        return self.simple_corner('top-left', c1, c2, curve, size1, size2).flop
      when 'bottom-right'
        return self.simple_corner('top-left', c1, c2, curve, size1, size2).flop.flip
      else
        raise 'Invalid direction'
    end
  end
  
  def self.max_size
    100
  end
  
  def self.clean_color(c)
    unless c.nil?
      if c =~ /[a-fA-F0-9]{6,6}/
        c = '#' + c 
      else
        c
      end
    else
      nil
    end
  end

end
