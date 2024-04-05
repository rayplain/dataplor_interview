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

  # Returns the parent of the node using a recursive CTE query
  #
  # @return [Node] the root parent node
  def get_parent
    parent_cte = Arel::Table.new(:ParentHierarchy)
    select_manager = Nodes::ParentArelQuery.new(self).call
    select_manager.from(parent_cte).where(parent_cte[:parent_id].eq(nil))
    Node.find_by_sql(select_manager.to_sql).first
  end

  # Finds the lowest common ancestor (LCA) of two nodes
  #
  # @param node_a_id [Integer] the id of the first node
  # @param node_b_id [Integer] the id of the second node
  # @return [Hash] the LCA node, the LCA id, and the depth of the LCA
  def self.find_lca(node_a_id, node_b_id)
    return Nodes::FindLcaQuery.new(node_a_id, node_b_id).call
  end

  # Returns an Arel query to find all children and descendants of the node
  #
  # @return [Arel::SelectManager] the Arel query
  def all_children_arel
    Node.all_children_for_nodes_arel [id]
  end

  # Finds all descendants of the node
  #
  # @return [Array<Node>] an array of descendant nodes
  def all_descendants
    Node.find_by_sql all_children_arel.where(Arel::Table.new(:node_tree)[:level].gt(0)).to_sql
  end

  # Finds all descendants of the node and the node itself
  #
  # @return [Array<Node>] an array of descendant nodes and the node itself
  def all_descendants_and_self
    Node.find_by_sql all_children_arel.to_sql
  end

  # Finds all birds that belong to the descendants of a list of nodes
  #
  # @param node_ids [Array<Integer>] an array of node ids
  # @return [Array<Bird>] an array of birds
  def self.birds_from_descendants_for(node_ids)
    node_tree = Arel::Table.new(:node_tree)
    birds = Bird.arel_table

    base_query = all_children_for_nodes_arel(node_ids)
                   .join(birds)
                   .on(birds[:node_id].eq(node_tree[:id]))

    Bird.find_by_sql(base_query.to_sql)
  end

  # Returns an Arel query to find all children for a list of nodes
  #
  # @param node_ids [Array<Integer>] an array of node ids
  # @return [Arel::SelectManager] the Arel query
  def self.all_children_for_nodes_arel(node_ids)
    ::Nodes::AllChildrenForNodesArelQuery.new(node_ids).call
  end
end