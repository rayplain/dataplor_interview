FactoryBot.define do
  factory :bird do
    name { Faker::Creature::Bird.name }
    node
  end
end