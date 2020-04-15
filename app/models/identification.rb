class Identification < ApplicationRecord
  belongs_to :dro
  has_many :catalogLinks, dependent: :destroy
end
