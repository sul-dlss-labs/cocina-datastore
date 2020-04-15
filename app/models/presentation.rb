class Presentation < ApplicationRecord
  belongs_to :file, class_name: 'DroFile'
end
