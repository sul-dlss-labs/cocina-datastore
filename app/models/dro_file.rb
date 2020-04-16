# frozen_string_literal: true

class DroFile < ApplicationRecord
  self.table_name = 'droFiles'
  belongs_to :structural, class_name: 'FileSetStructural', foreign_key: 'fileSetStructural_id'
  has_many :hasMessageDigests, dependent: :destroy, class_name: 'MessageDigest', autosave: true, foreign_key: 'droFile_id'
  has_one :access, dependent: :destroy, foreign_key: 'droFile_id', autosave: true
  has_one :administrative, dependent: :destroy, class_name: 'FileAdministrative', foreign_key: 'droFile_id', autosave: true
  has_one :presentation, dependent: :destroy, foreign_key: 'droFile_id', autosave: true

  # Used to determine identity for item of an array.
  # Perhaps can introspect this from unique indexes, e.g., ActiveRecord::Base.connection.indexes(:table_name)
  mattr_accessor :unique_fields
  self.unique_fields = ['externalIdentifier']
end
