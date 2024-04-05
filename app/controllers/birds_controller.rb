class BirdsController < ApplicationController
  def index
    node_ids = params[:node_ids].split(',').map(&:to_i)
    birds = Nodes::FindAllBirds.new(node_ids).call
    render json: birds
  end
end
