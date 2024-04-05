# The Nodes::FindLcaQuery class is used to find the lowest common ancestor (LCA)
# of two nodes in a tree.
class Nodes::FindLcaQuery
  attr_accessor :root_id, :lowest_common_ancestor_id, :depth, :root, :node_a, :node_b, :parent_a, :parent_b, :path_a, :path_b

  # Initializes a new instance of the Nodes::FindLcaQuery class
  #
  # @param node_a_id [Integer] the id of the first node
  # @param node_b_id [Integer] the id of the second node
  def initialize(node_a_id, node_b_id)
    @node_a_id = node_a_id
    @node_b_id = node_b_id
  end

  # Finds the LCA of two nodes
  #
  # @return [Hash] a hash containing the LCA node, the LCA id, and the depth of the LCA
  def call
    find_nodes
    return result if node_a.nil? || node_b.nil?

    get_parents
    return result if parent_a.nil? || parent_b.nil? || parent_a != parent_b

    calculate_paths
    find_lca
    calculate_depth

    result
  end

  private

  # Finds the two nodes
  #
  # @return [void]
  def find_nodes
    @node_a = Node.find_by(id: @node_a_id)
    @node_b = Node.find_by(id: @node_b_id)
  end

  # Gets the parents of the two nodes
  #
  # @return [void]
  def get_parents
    node_parents = get_parents_for_nodes(node_a, node_b)
    return if node_parents.empty? || node_parents.map{|node| node.id}.uniq.length > 1
    #This area here is definitely where some performance tuning can happen when we have processed data
    @parent_a = node_parents.find { |node| node.path.split("->").first.to_i == node_a.id }
    @parent_b = node_parents.find { |node| node.path.split("->").first.to_i == node_b.id }
    @root_id = parent_a.id if parent_a == parent_b
  end

  def get_parents_for_nodes(node, node_b = nil)
    parent_cte = Arel::Table.new(:ParentHierarchy)
    select_manager = Nodes::ParentArelQuery.new(node, node_b).call
    select_manager.from(parent_cte).where(parent_cte[:parent_id].eq(nil))
    Node.find_by_sql(select_manager.to_sql)
  end

  # Calculates the paths from the root to the two nodes
  #
  # @return [void]
  def calculate_paths
    @path_a = parent_a.path.split('->').map(&:to_i)
    @path_b = parent_b.path.split('->').map(&:to_i)
    node_a.level = path_a.length - 1
    node_b.level = path_b.length - 1
    node_a.path = parent_a.path
    node_b.path = parent_b.path
    path_a.reverse!
    path_b.reverse!
  end

  # Finds the LCA of the two nodes
  #
  # @return [void]
  def find_lca
    lca_id = path_a.first
    path_a.zip(path_b).each do |a, b|
      break if a != b
      lca_id = a
    end
    @lowest_common_ancestor_id = lca_id
  end

  # Calculates the depth of the LCA
  #
  # @return [void]
  def calculate_depth
    depth = 0
    while depth < path_a.length && depth < path_b.length && path_a[depth] == path_b[depth]
      depth += 1
    end
    @depth = depth
  end

  # Returns the result
  #
  # @return [Hash] a hash containing the LCA node, the LCA id, and the depth of the LCA
  def result
    { root_id: root_id, lowest_common_ancestor_id: lowest_common_ancestor_id, depth: depth }
  end
end