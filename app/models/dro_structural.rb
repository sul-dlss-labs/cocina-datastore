class DroStructural < ApplicationRecord
  self.table_name = "droStructurals"
  belongs_to :dro, inverse_of: :structural
  has_many :hasMemberOrders, dependent: :destroy, class_name: 'Sequence'
  has_many :contains, dependent: :destroy, class_name: 'FileSet'
end
