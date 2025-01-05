FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) {|n| "#{n}_#{Faker::Internet.email}" }
    password {|n| "#{n}_#{Faker::Internet.password}" }
  end
end
