# frozen_string_literal: true

class DroStructural < ApplicationRecord
  self.table_name = 'droStructurals'
  belongs_to :dro, inverse_of: :structural
  has_many :hasMemberOrders, dependent: :destroy, class_name: 'Sequence', autosave: true, foreign_key: 'droStructural_id'
  has_many :contains, dependent: :destroy, class_name: 'FileSet', autosave: true, foreign_key: 'droStructural_id'
end
