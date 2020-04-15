class Administrative < ApplicationRecord
  belongs_to :dro
  has_many :releaseTags, dependent: :destroy
end
