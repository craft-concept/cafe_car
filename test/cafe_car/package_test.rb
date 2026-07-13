require "test_helper"

class CafeCar::PackageTest < ActiveSupport::TestCase
  setup { @files = Gem::Specification.load(CafeCar::Engine.root.join("cafe_car.gemspec").to_s).files }

  test "the gem includes its public project documents" do
    %w[CHANGELOG.md CODE_OF_CONDUCT.md CONTRIBUTING.md README.md SECURITY.md].each do |file|
      assert_includes @files, file
    end
  end

  test "the gem excludes development and dummy-app artifacts" do
    forbidden = %w[
      Rakefile
      config/brakeman.ignore
      db/migrate/20251005220017_create_slugs.rb
      app/views/passwords_mailer/reset.html.haml
      app/views/passwords_mailer/reset.text.erb
    ]

    forbidden.each { |file| assert_not_includes @files, file }
  end
end
