FactoryGirl.define do
  sequence :title do |n|
    "The issue title №#{n}"
  end

  factory :issue do
    title
    description 'The Issue Description'
  end
end
