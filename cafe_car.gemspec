require_relative "lib/cafe_car/version"

Gem::Specification.new do |spec|
  spec.name        = "cafe_car"
  spec.version     = CafeCar::VERSION
  spec.authors     = [ "Jeff Peterson" ]
  spec.email       = [ "jeff@yak.sh" ]
  spec.homepage    = "https://craft-concept.github.io/cafe_car"
  spec.summary     = "A composable view extension for Rails — render index, show, new, and edit straight from your models, with keyword search, filtering, CSV export, and Pundit authorization, then override any default with ordinary Rails."
  spec.description = <<~DESC.tr("\n", " ").strip
    CafeCar is a composable view extension for Rails: it renders complete index, show, new,
    and edit interfaces straight from your models, with no DSL and no boilerplate. Every
    index ships with keyword search, URL-based filtering and sorting, pagination, and
    one-click CSV export. Authorization runs on Pundit with attribute-level permissions;
    forms and Turbo Stream (Hotwire) responses render automatically. Every default can be
    overridden application-wide or per model with ordinary Rails. It makes admin panels,
    internal tools, and back-office apps on Rails 8 trivial.
  DESC
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.3"

  spec.metadata["homepage_uri"]          = spec.homepage
  spec.metadata["source_code_uri"]       = "https://github.com/craft-concept/cafe_car"
  spec.metadata["changelog_uri"]         = "https://github.com/craft-concept/cafe_car/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"]       = "https://github.com/craft-concept/cafe_car/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib,skills}/**/*", ".claude-plugin/**/*", "llms.txt", "CHANGELOG.md",
        "CODE_OF_CONDUCT.md", "CONTRIBUTING.md", "MIT-LICENSE", "README.md", "SECURITY.md"]
      .reject { _1 == "config/brakeman.ignore" }
  end

  spec.add_dependency "rails", ">= 8.0", "< 9"
  spec.add_dependency "responders", ">= 3.0", "< 4"
  spec.add_dependency "activerecord_where_assoc", ">= 1.3", "< 2"
  spec.add_dependency "propshaft", ">= 1.0", "< 2"
  spec.add_dependency "haml-rails", ">= 3.0", "< 4"
  spec.add_dependency "image_processing", ">= 1.13", "< 3"
  spec.add_dependency "importmap-rails", ">= 2.0", "< 3"
  spec.add_dependency "turbo-rails", ">= 2.0", "< 3"
  spec.add_dependency "kaminari", ">= 1.2", "< 2"
  spec.add_dependency "potter", ">= 0.1.1", "< 0.2"
  spec.add_dependency "pundit", ">= 2.0", "< 3"
  spec.add_dependency "chronic", ">= 0.10", "< 1"

  spec.add_dependency "rouge", ">= 4.0", "< 6"
end
