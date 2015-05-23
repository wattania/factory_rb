FactoryGirl.define do
  factory :user do
    user_name UUID.generate
    email "rspec@a.com"
    password "password"
    first_name "rspec-firstname"
  end

end
 