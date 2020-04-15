class Dro < ApplicationRecord
  has_one :access, dependent: :destroy, class_name: 'DroAccess'
  has_one :structural, dependent: :destroy, class_name: 'DroStructural'

  def to_cocina_model
    Cocina::Models::DRO.new(to_cocina_json)
  end
end
