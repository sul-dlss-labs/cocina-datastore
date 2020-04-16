# frozen_string_literal: true

class Sequence < ApplicationRecord
  # self.table_name = "hasMemberOrders"
  belongs_to :dro_structural, class_name: 'DroStructural', inverse_of: :hasMemberOrders, autosave: true, foreign_key: 'droStructural_id'

  # Used to determine identity for item of an array.
  # Perhaps can introspect this from unique indexes, e.g., ActiveRecord::Base.connection.indexes(:table_name)
  mattr_accessor :unique_fields
  self.unique_fields = ['viewingDirection']
end
