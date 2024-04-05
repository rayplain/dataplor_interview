class BirdsController < ApplicationController
  def index
    node_ids = params[:node_ids].split(',').map(&:to_i)
    birds = Bird.birds_from_nodes(node_ids)
    render json: birds
  end
end
