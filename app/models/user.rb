class User < ActiveRecord::Base
  has_and_belongs_to_many :pbx_queues
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :registerable
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Available roles
  def self.role_enum
    ['agent', 'admin', 'manager']
  end

  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :pbx_queue_ids, :extension

  validates :role, :presence => true
  validates :extension, :uniqueness => true
  validates :email, :uniqueness => true
  
  rails_admin do
    object_label_method do
      custom_label_method
    end
    
    def custom_label_method
      "#{:email}"
    end
  end
  
  after_initialize do
    if new_record?
      self.role ||= 'agent'
    end
  end
end
