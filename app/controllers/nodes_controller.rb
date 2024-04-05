class NodesController < ApplicationController
  def common_ancestor
    node_a_id = params[:node_a_id].to_i
    node_b_id = params[:node_b_id].to_i
    common_ancestors = Node.find_lca(node_a_id, node_b_id)
    render json: common_ancestors
  end
end