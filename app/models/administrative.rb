# frozen_string_literal: true

class Administrative < ApplicationRecord
  belongs_to :dro
  has_many :releaseTags, dependent: :destroy, autosave: true
end
