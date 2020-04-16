# frozen_string_literal: true

class Identification < ApplicationRecord
  belongs_to :dro
  has_many :catalogLinks, dependent: :destroy, autosave: true
end
