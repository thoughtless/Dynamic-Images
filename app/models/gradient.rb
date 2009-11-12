require 'RMagick'
include Magick

class Gradient < ActiveRecord::Base

  def self.simple(direction='top-left', c1='#ffffff', c2='#000000', size1=50, size2=nil)
  
    c1 = self.clean_color c1
    c2 = self.clean_color c2
  
    direction ||= 'top-left'
    c1 ||= '#ffffff'
    c2 ||= '#000000'
    size1 ||= 50
    
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
    
    r = self.simple_gradient(direction, c1, c2, size1, size2)
    r.format=('PNG')
    r.compression=(Magick::ZipCompression)
    
    r#.to_blob {|i| i.quality = 0}
  end
  
  protected

  def self.simple_gradient(direction='top-left', c1='#ffffff', c2='#000000', size1=50, size2=nil)
    case direction
      when 'top-left'
        size2 ||= size1 #default to a square
        
        mask = Image.new(size1,size2,GradientFill.new(size1,0,0,0,'black','white'))
        mask.matte=false
        
        c1_bkg = Image.new(size1,size2) {|i| i.background_color = c1}
        c2_bkg = Image.new(size1,size2) {|i| i.background_color = c2}
        
        c1_bkg.matte=true
        c2_bkg.matte=false
        
        c1_bkg.composite!(mask, 0,0, CopyOpacityCompositeOp)
        
        c1_bkg.composite!(c1_bkg.resize(size2,size1).rotate(90), CenterGravity, OverCompositeOp).flip!
        
        c1_bkg.matte=true
        r = c2_bkg.composite(c1_bkg, CenterGravity, OverCompositeOp)
        
        #shift the image by 1 px so that it line up with the 'top' and 'left' directions
        r.border!(1,1,c1)
        r.crop!(NorthWestGravity,r.columns - 2, r.rows - 2, true)
        
        return r
      when 'left'
        x1, y1, x2 = 0, 0, 0
        y2 = size1
        size2 ||= 5
        width, height = size1, size2
      when 'top'
        x1, y1, y2 = 0, 0, 0
        x2 = size1
        size2 ||= 5
        width, height = size2, size1  #reversed
      when 'bottom-left'
        return self.simple_gradient('top-left', c1, c2, size1, size2).flip
      when 'bottom'
        return self.simple_gradient('top', c1, c2, size1, size2).flip
      when 'right'
        return self.simple_gradient('left', c1, c2, size1, size2).flop
      when 'top-right'
        return self.simple_gradient('top-left', c1, c2, size1, size2).flop
      when 'bottom-right'
        return self.simple_gradient('top-left', c1, c2, size1, size2).flop.flip
      else
        raise 'Invalid direction'
    end
    Magick::Image.new(width, height, Magick::GradientFill.new(x1, y1, x2, y2, c1, c2))
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
