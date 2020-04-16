# frozen_string_literal: true

class FileSetStructural < ApplicationRecord
  self.table_name = 'fileSetStructurals'

  belongs_to :fileSet, inverse_of: :structural
  has_many :contains, dependent: :destroy, class_name: 'DroFile', autosave: true, foreign_key: 'fileSetStructural_id'
end
