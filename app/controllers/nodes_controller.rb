class NodesController < ApplicationController
  def common_ancestor
    node_a_id = params[:node_a_id].to_i
    node_b_id = params[:node_b_id].to_i
    common_ancestors = Nodes::FindLcaQuery.new(node_a_id, node_b_id).call
    render json: common_ancestors
  end
end