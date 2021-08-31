class User < ApplicationRecord
  authenticates_with_sorcery!

  attr_accessor :password, :password_confirmation, :token

  CELLPHONE_RE = /\A(\+86|86)?1\d{10}\z/
  EMAIL_RE = /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/

  # validates_presence_of :email, message: "E-mail can not be empty"
  # validates_format_of :email, message: "Invalid email format",
  #   with: /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/,
  #   if: proc { |user| !user.email.blank? }
  # validates :email, uniqueness: true

  validates_presence_of :password, message: "password can not be empty",
    if: :need_validate_password
  validates_presence_of :password_confirmation, message: "Password confirmation cannot be empty",
    if: :need_validate_password
  validates_confirmation_of :password, message: "Inconsistent passwords",
    if: :need_validate_password
  validates_length_of :password, message: "The minimum password is 6 digits", minimum: 6,
    if: :need_validate_password

  validate :validate_email_or_cellphone, on: :create

  has_many :addresses, -> { where(address_type: Address::AddressType::User).order("id desc") }
  belongs_to :default_address, class_name: :Address
  has_many :orders
  has_many :payments

  def username
    self.email.blank? ? self.cellphone : self.email.split('@').first
  end

  private
  def need_validate_password
    self.new_record? ||
      (!self.password.nil? || !self.password_confirmation.nil?)
  end

  # TODO
  # Need to add a verification that the mailbox and phone number cannot be repeated
  def validate_email_or_cellphone
    if [self.email, self.cellphone].all? { |attr| attr.nil? }
      self.errors.add :base, "E-mail and mobile phone number can not be empty"
      return false
    else
      if self.cellphone.nil?
        if self.email.blank?
          self.errors.add :email, "E-mail can not be empty"
          return false
        else
          unless self.email =~ EMAIL_RE
            self.errors.add :email, "E-mail format is incorrect"
            return false
          end
        end
      else
        unless self.cellphone =~ CELLPHONE_RE
          self.errors.add :cellphone, "Phone number format is incorrect"
          return false
        end

        unless VerifyToken.available.find_by(cellphone: self.cellphone, token: self.token)
          self.errors.add :cellphone, "The phone verification code is incorrect or has expired"
          return false
        end
      end
    end

    return true
  end
end
