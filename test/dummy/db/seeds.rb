include FactoryBot::Syntax::Methods

def group(label)
  print "Creating #{label}... "
  yield
  puts "Done."
end

group "users" do
  create_list :user, 20
end

group "articles" do
  create_list :article, 70, :content, :sample_author, :published
  create_list :article, 30, :content, :sample_author, :draft
end

puts "\nAccounting:"

group "clients" do
  create_list(:client, 35)
end

group "invoices" do
  create_list(:invoice, 200, :sample_client)
end
