FactoryGirl.define do
  sequence :email do |n|
    "tracker_test#{n}@studytube.nl"
  end

  factory :user do
    email
    password '12345678'
    password_confirmation '12345678'
    confirmed_at DateTime.now
  end
end
