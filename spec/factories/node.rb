FactoryBot.define do
  factory :node do
    level { rand(1..10) }
    path { Faker::Internet.uuid }

    after(:build) do |node, evaluator|
      node.parent ||= create(:node) if evaluator.parent
    end
  end
end