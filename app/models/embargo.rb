class Embargo < ApplicationRecord
  self.table_name = "embargoes"

  # Naming droAccess, since has attribute named access
  belongs_to :droAccess, class_name: 'DroAccess'
end
