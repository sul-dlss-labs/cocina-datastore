# frozen_string_literal: true

class DroAccess < ApplicationRecord
  self.table_name = 'droAccesses'

  belongs_to :dro
  has_one :embargo, dependent: :destroy, foreign_key: 'droAccess_id', autosave: true
end
