require 'uuidtools'

class AccessKey < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user_id
  
  validates_presence_of :user_id, :key
  validates_uniqueness_of :key
  
  def before_validation_on_create
    new_key
  end
  
  def new_key
    self.key = UUID.random_create.to_s
  end
end
