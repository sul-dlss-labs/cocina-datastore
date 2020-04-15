# frozen_string_literal: true

class MessageDigest < ApplicationRecord
  self.table_name = 'messageDigests'
  belongs_to :file, class_name: 'DroFile'

  # Used to determine identity for item of an array.
  # Perhaps can introspect this from unique indexes, e.g., ActiveRecord::Base.connection.indexes(:table_name)
  mattr_accessor :unique_fields
  self.unique_fields = ['type']
end
