# frozen_string_literal: true

class FileSet < ApplicationRecord
  self.table_name = 'fileSets'
  # Have to name this droStructural, since there is already an attribute named structural.
  belongs_to :droStructural, class_name: 'DroStructural'
  has_one :structural, dependent: :destroy, class_name: 'FileSetStructural', foreign_key: 'fileSet_id', autosave: true

  # Used to determine identity for item of an array.
  # Perhaps can introspect this from unique indexes, e.g., ActiveRecord::Base.connection.indexes(:table_name)
  mattr_accessor :unique_fields
  self.unique_fields = ['externalIdentifier']
end
