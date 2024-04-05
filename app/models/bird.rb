class Bird < ApplicationRecord
  belongs_to :node, optional: true


end