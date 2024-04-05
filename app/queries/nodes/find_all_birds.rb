class Nodes::FindAllBirds
  attr_accessor :node_ids
  # @param node_ids [Array<Integer>] an array of Nodes
  def initialize(node_ids)
    @node_ids = node_ids
  end

  def call
    node_tree = Arel::Table.new(:node_tree)
    birds = Bird.arel_table
    select_manager = Nodes::AllChildrenForNodesArelQuery.new(node_ids).call

    base_query = select_manager
                   .join(birds)
                   .on(birds[:node_id].eq(node_tree[:id]))

    Bird.find_by_sql(base_query.to_sql)
  end
end