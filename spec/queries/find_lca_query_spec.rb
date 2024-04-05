require 'rails_helper'
RSpec.describe Nodes::FindLcaQuery, type: :query do
  describe '#call' do
    context 'when nodes have a common ancestor' do
      it 'returns the lowest common ancestor of two nodes' do
        root_node = create(:node)
        child_node_a = create(:node, parent: root_node)
        child_node_b = create(:node, parent: root_node)
        query = ::Nodes::FindLcaQuery.new(child_node_a.id, child_node_b.id)

        result = query.call

        expect(result).to eq({ root_id: root_node.id , lowest_common_ancestor_id: root_node.id, depth: 1 })
      end
    end

    context 'when nodes have no common ancestor' do
      it 'returns a blank result' do
        node_a = create(:node)
        node_b = create(:node)
        query = ::Nodes::FindLcaQuery.new(node_a.id, node_b.id)

        result = query.call

        expect(result).to eq({ root_id: nil, lowest_common_ancestor_id: nil, depth: nil })
      end
    end

    context 'when one or both nodes do not exist' do
      it 'returns a blank result' do
        node_a = create(:node)
        query = ::Nodes::FindLcaQuery.new(node_a.id, Node.maximum(:id).next)

        result = query.call

        expect(result).to eq({ root_id: nil, lowest_common_ancestor_id: nil, depth: nil })
      end
    end
  end
end