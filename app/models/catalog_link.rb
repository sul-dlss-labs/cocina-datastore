# frozen_string_literal: true

class CatalogLink < ApplicationRecord
  self.table_name = 'catalogLinks'
  belongs_to :identification

  # Used to determine identity for item of an array.
  # Perhaps can introspect this from unique indexes, e.g., ActiveRecord::Base.connection.indexes(:table_name)
  mattr_accessor :unique_fields
  self.unique_fields = ['catalog']
end
