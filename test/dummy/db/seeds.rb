include FactoryBot::Syntax::Methods

def group(label)
  print "Creating #{label}... "
  yield
  puts "Done."
end

group "users" do
  # A known account so "Enter the demo" can sign visitors in (see User::DEMO_*).
  create(:user, name: "Ada Demo", email: User::DEMO_EMAIL,
                password: User::DEMO_PASSWORD, password_confirmation: User::DEMO_PASSWORD)
  create_list(:user, 20)
end

group "articles" do
  create_list(:article, 70, :content, :published)
  create_list(:article, 30, :content, :draft)
end

puts "\nAccounting:"

group "clients" do
  create_list(:client, 10)
end

group "invoices" do
  create_list(:invoice, 200)
end
