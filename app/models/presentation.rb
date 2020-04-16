# frozen_string_literal: true

class Presentation < ApplicationRecord
  belongs_to :file, class_name: 'DroFile', foreign_key: 'droFile_id'
end
