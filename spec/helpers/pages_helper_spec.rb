require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

describe PagesHelper do
  include PagesHelper

#    "<span class=\"example\"><span class=\"example-path\">#{path}</span>" + image_tag(prefix + path, :alt => path) + '</span>'

  it "should return the html" do
    result = example('prefix/', 'gradient')
    result.should == '<span class="example"><span class="example-path">gradient</span>' + image_tag('prefix/gradient', :alt => 'gradient') + '</span>'
  end
  
end
