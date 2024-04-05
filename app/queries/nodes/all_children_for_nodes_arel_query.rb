# The Nodes::AllChildrenForNodesArelQuery class is used to build an Arel query
# that finds all children and descendants for a list of nodes.
#
class Nodes::AllChildrenForNodesArelQuery
  # Initializes a new instance of the Nodes::AllChildrenForNodesArelQuery class
  #
  # @param node_ids [Array<Integer>] an array of node ids
  def initialize(node_ids)
    @node_ids = node_ids
  end

  # Builds an Arel query to find all children and descendants for a list of nodes
  #
  # @return [Arel::SelectManager] the Arel query
  def call
    nodes = Node.arel_table
    node_tree = Arel::Table.new(:node_tree)

    # Base case: select nodes that are in the list of node ids
    base_case = nodes
                  .project(*(Node.column_names).map { |col| nodes[col] }, Arel.sql('0 AS level'))
                  .where(nodes[:id].in(@node_ids))

    # Recursive case: select nodes that are children of nodes in the node_tree
    recursive_case = nodes
                       .project(*(Node.column_names).map { |col| nodes[col] }, (node_tree[:level] + 1).as('level'))
                       .join(node_tree)
                       .on(nodes[:parent_id].eq(node_tree[:id]))

    # Combine the base case and recursive case using a recursive CTE
    cte = Arel::Nodes::As.new(
      node_tree,
      Arel::Nodes::UnionAll.new(base_case, recursive_case)
    )

    # Return the final query
    node_tree
      .project(Arel.star)
      .with(:recursive, cte)
  end
end