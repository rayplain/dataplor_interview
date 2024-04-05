# spec/models/node_spec.rb

require 'rails_helper'

RSpec.describe Node, type: :model do
  def blank_find_lca_query_result
    {
      root_id: nil,
      lowest_common_ancestor_id: nil,
      depth: nil,
    }
  end

  describe '#get_parent' do
    context 'when node has a parent' do
      it 'returns the parent of the node' do
        parent_node = create(:node)
        child_node = create(:node, parent: parent_node)

        expect(child_node.get_parent).to eq(parent_node)
      end
    end
    context 'when node is deeply nested' do
      it 'returns the root node' do
        root_node = create(:node)
        child_node = create(:node, parent: root_node)
        grandchild_node = create(:node, parent: child_node)
        great_grandchild_node = create(:node, parent: grandchild_node)

        expect(great_grandchild_node.get_parent).to eq(root_node)
      end
    end
  end

  describe '#all_descendants' do
    context 'when node has descendants' do
      it 'returns all descendants of the node' do
        root_node = create(:node)
        child_node = create(:node, parent: root_node)
        grandchild_node = create(:node, parent: child_node)

        expect(root_node.all_descendants).to contain_exactly(child_node, grandchild_node)
      end
    end

    context 'when node has no descendants' do
      it 'returns an empty array' do
        node = create(:node)

        expect(node.all_descendants).to be_empty
      end
    end
  end

  describe '#all_descendants_and_self' do
    context 'when node has descendants' do
      it 'returns all descendants of the node and the node itself' do
        root_node = create(:node)
        child_node = create(:node, parent: root_node)
        grandchild_node = create(:node, parent: child_node)

        expect(root_node.all_descendants_and_self).to contain_exactly(root_node, child_node, grandchild_node)
      end
    end

    context 'when node has no descendants' do
      it 'returns an array with only the node itself' do
        node = create(:node)

        expect(node.all_descendants_and_self).to contain_exactly(node)
      end
    end
  end

  describe '.find_lca' do
    context 'when nodes have a common ancestor' do
      it 'returns the lowest common ancestor of two nodes' do
        root_node = create(:node)
        child_node_a = create(:node, parent: root_node)
        child_node_b = create(:node, parent: root_node)

        expect(Node.find_lca(child_node_a.id, child_node_b.id)).to eq({ root_id: root_node.id , lowest_common_ancestor_id: root_node.id, depth: 1 })
      end
    end

    context 'when nodes have no common ancestor' do
      it 'returns a blank FindLcaQuery result' do
        node_a = create(:node)
        node_b = create(:node)

        expect(Node.find_lca(node_a.id, node_b.id)).to eq(blank_find_lca_query_result)
      end
    end
  end

  describe '.birds_from_descendants_for' do
    context 'when nodes have birds' do
      it 'returns all birds that belong to the descendants of a list of nodes' do
        root_node = create(:node)
        child_node = create(:node, parent: root_node)
        bird = create(:bird, node: child_node)

        expect(Node.birds_from_descendants_for([root_node.id])).to contain_exactly(bird)
      end
    end

    context 'when nodes have no birds' do
      it 'returns an empty array' do
        node = create(:node)

        expect(Node.birds_from_descendants_for([node.id])).to be_empty
      end
    end
  end
end