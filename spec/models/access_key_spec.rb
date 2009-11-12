require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

describe AccessKey do

  before(:each) do
    @john = stub(User, :id => 1)
  end

  it "should ignore the key value that is passed when created" do
    my_key = 'bnhdaudoeaueo'
    k = AccessKey.new(:user_id => @john.id, :key => my_key)
    k.key.should_not eql(my_key)
  end
  
  it "should be valid when passed only a user_id" do
    k = valid_key
    k.should be_valid
  end
  
  it "should be able to change keys" do
    k = valid_key
    tmp = k.key
    k.new_key
    k.save
    k.key.should_not eql(tmp)
  end
  
  def valid_key
    AccessKey.new(:user_id => @john.id)
  end
  
end
