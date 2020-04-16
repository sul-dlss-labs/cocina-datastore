# frozen_string_literal: true

class FileAdministrative < ApplicationRecord
  self.table_name = 'fileAdministratives'
  belongs_to :file, class_name: 'DroFile', foreign_key: 'droFile_id'
end
