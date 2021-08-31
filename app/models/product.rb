class Product < ApplicationRecord

  validates :category_id, presence: { message: "Category cannot be empty" }
  validates :title, presence: { message: "title cannot be empty" }
  validates :status, inclusion: { in: %w[on off], 
    message: "The product status must be on | off" }
  validates :amount, numericality: { only_integer: true,
    message: "Inventory must be an integer" },
    if: proc { |product| !product.amount.blank? }
  validates :amount, presence: { message: "Inventory cannot be empty" }
  validates :msrp, presence: { message: "MSRP cannot be empty" }
  validates :msrp, numericality: { message: "MSRP must be a number" },
    if: proc { |product| !product.msrp.blank? }
  validates :price, numericality: { message: "Price must be a number" },
    if: proc { |product| !product.price.blank? }
  validates :price, presence: { message: "Price cannot be empty" }
  validates :description, presence: { message: "Description cannot be empty" }

  belongs_to :category
  has_many :product_images, -> { order(weight: 'desc') },
    dependent: :destroy
  has_one :main_product_image, -> { order(weight: 'desc') },
    class_name: :ProductImage

  before_create :set_default_attrs

  scope :onshelf, -> { where(status: Status::On) }

  module Status
    On = 'on'
    Off = 'off'
  end

  private
  def set_default_attrs
    self.uuid = RandomCode.generate_product_uuid
  end
end
