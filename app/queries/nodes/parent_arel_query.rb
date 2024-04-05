# The Nodes::ParentArelQuery class is used to build an Arel query
# that finds the parent of a node.
class Nodes::ParentArelQuery
  # Initializes a new instance of the Nodes::ParentArelQuery class
  #
  # @param node [Node] the node for which to find the root parent
  def initialize(node, node_b = nil)
    @node = node
    @node_b = node_b
  end

  # Builds an Arel query to find the root parent of a node
  #
  # @return [Arel::SelectManager] the Arel query
  def call
    parent_cte = Arel::Table.new(:ParentHierarchy)
    nodes = Node.arel_table

    # Anchor member: select the node
    # @return [Arel::SelectManager] the anchor member Arel query
    where_nodes = nodes[:id].in([@node.id, @node_b.id].compact)
    anchor_member = nodes
                      .project(nodes[:id], nodes[:parent_id], Arel::Nodes::NamedFunction.new('CAST', [nodes[:id].as('VARCHAR')]).as('path'), Arel.sql('0 AS level'))
                      .where(where_nodes)
    # Recursive member: select the parent of the node
    # @return [Arel::SelectManager] the recursive member Arel query
    recursive_member = nodes
                         .project(nodes[:id],
                                  nodes[:parent_id],
                                  Arel::Nodes::NamedFunction.new('CONCAT', [parent_cte[:path], Arel::Nodes.build_quoted('->'), Arel::Nodes::NamedFunction.new('CAST', [nodes[:id].as('VARCHAR')])]),
                                  (parent_cte[:level] + 1).as('level'))
                         .join(parent_cte)
                         .on(nodes[:id].eq(parent_cte[:parent_id]))

    # Combine the anchor member and recursive member using a recursive CTE
    # @return [Arel::Nodes::As] the combined Arel query
    parent_hierarchy = Arel::Nodes::As.new(parent_cte, Arel::Nodes::UnionAll.new(anchor_member, recursive_member))

    # Return the final query
    # @return [Arel::SelectManager] the final Arel query
    Arel::SelectManager.new
                       .with(:recursive, parent_hierarchy)
                       .project(parent_cte[:id], parent_cte[:parent_id], parent_cte[:path])
                       .from(parent_cte)
  end
end