class FileAdministrative < ApplicationRecord
  self.table_name = "fileAdministratives"
  belongs_to :file, class_name: 'DroFile'
end
