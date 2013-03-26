class PbxQueue < ActiveRecord::Base
  has_and_belongs_to_many :users
  
  attr_accessible :description, :name, :user_ids
  
  validates :name, :presence => true
end
