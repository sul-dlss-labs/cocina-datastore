class Access < ApplicationRecord
  belongs_to :file, class_name: 'DroFile'
end
