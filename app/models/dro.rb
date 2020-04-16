# frozen_string_literal: true

class Dro < ApplicationRecord
  has_one :access, dependent: :destroy, class_name: 'DroAccess', autosave: true
  has_one :structural, dependent: :destroy, class_name: 'DroStructural', autosave: true
  has_one :administrative, dependent: :destroy, autosave: true
  has_one :identification, dependent: :destroy, autosave: true
  has_one :geographic, dependent: :destroy, autosave: true

  def to_cocina_model
    Cocina::Models::DRO.new(to_cocina_json)
  end
end
