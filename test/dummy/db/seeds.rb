include FactoryBot::Syntax::Methods

# Each group skips itself when its rows already exist, so re-running seeds
# (e.g. a redeploy against a surviving database) never duplicates rows or
# crashes on unique indexes.
def group(label, skip: false)
  if skip
    puts "Skipping #{label} (already seeded)."
    return
  end
  print "Creating #{label}... "
  yield
  puts "Done."
end

DOCUMENTS = Rails.root.join("db/seeds/documents").glob("*").freeze

group "users", skip: User.any? do
  # A known account so "Enter the demo" can sign visitors in (see User::DEMO_*).
  create(:user, name: "Ada Demo", email: User::DEMO_EMAIL,
                password: User::DEMO_PASSWORD, password_confirmation: User::DEMO_PASSWORD)
  # Varied statuses so the index shows the full Badge palette.
  create_list(:user, 12)
  create_list(:user, 5, status: "pending")
  create_list(:user, 3, status: "archived")
  # A few users carry documents so `has_many_attached` fields have files to show.
  User.order(:id).limit(8).each do |user|
    DOCUMENTS.sample(rand(1..DOCUMENTS.size)).each do |file|
      user.documents.attach(io: file.open, filename: file.basename.to_s)
    end
  end
end

group "articles", skip: Article.any? do
  create_list(:article, 70, :content, :published)
  create_list(:article, 30, :content, :draft)
end

puts "\nAccounting:"

group "clients", skip: Client.any? do
  create_list(:client, 7)
  create_list(:client, 3, status: :archived)
end

group "invoices", skip: Invoice.any? do
  create_list(:invoice, 150)
  create_list(:invoice, 50, paid: true)
end

group "notes", skip: Note.any? do
  create_list(:note, 12)
end
