# The Node class represents a node in an adjacency tree structure.
# Each node has a parent and can have many children.
# Each node also has many birds.
class Node < ApplicationRecord
  attribute :level, default: 0
  attribute :path, default: ''
  belongs_to :parent, class_name: 'Node', optional: true
  has_many :children, class_name: 'Node', foreign_key: 'parent_id'
  has_many :birds

  # Scope to find root nodes (nodes with no parent)
  scope :roots, -> { where(parent_id: nil) }


end