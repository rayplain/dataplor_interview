class Bird < ApplicationRecord
  belongs_to :node, optional: true

  def self.birds_from_nodes(node_ids)
    Node.birds_from_descendants_for(node_ids)
  end
end