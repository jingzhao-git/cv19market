class Address < ApplicationRecord

  validates :user_id, presence: true
  validates :address_type, presence: true
  validates :contact_name, presence: { message: "Consignee cannot be empty" }
  validates :cellphone, presence: { message: "Mobile cannot be empty" }
  validates :address, presence: { message: "Address cannot be empty" }

  belongs_to :user

  attr_accessor :set_as_default

  after_save :set_as_default_address
  before_destroy :remove_self_as_default_address

  module AddressType
    User = 'user'
    Order = 'order'
  end

  private
  def set_as_default_address
    if self.set_as_default.to_i == 1
      self.user.default_address = self
      self.user.save!
    else
      remove_self_as_default_address
    end
  end

  def remove_self_as_default_address
    if self.user.default_address == self
      self.user.default_address = nil
      self.user.save!
    end
  end


end
