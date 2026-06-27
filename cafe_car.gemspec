require_relative "lib/cafe_car/version"

Gem::Specification.new do |spec|
  spec.name        = "cafe_car"
  spec.version     = CafeCar::VERSION
  spec.authors     = [ "Jeff Peterson" ]
  spec.email       = [ "jeff@yak.sh" ]
  spec.homepage    = "https://craft-concept.github.io/cafe_car"
  spec.summary     = "Auto-generate CRUD admin UI for your Rails models, with sensible overridable defaults."
  spec.description = <<~DESC.tr("\n", " ").strip
    CafeCar is a Rails engine that extends the view layer to render complete index, show,
    new, and edit interfaces straight from your models, with no boilerplate required.
    Sensible defaults cover authorization, presenters, filtering, sorting, pagination, and
    Hotwire-ready forms, and every default can be overridden application-wide or per model.
    Batteries included for admin panels, internal tools, and rapid prototyping.
  DESC
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.3"

  spec.metadata["homepage_uri"]          = spec.homepage
  spec.metadata["source_code_uri"]       = "https://github.com/craft-concept/cafe_car"
  spec.metadata["changelog_uri"]         = "https://github.com/craft-concept/cafe_car/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"]       = "https://github.com/craft-concept/cafe_car/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "responders", ">= 3.0"
  spec.add_dependency "activerecord_where_assoc", ">= 1.3"
  spec.add_dependency "propshaft", ">= 1.0"
  spec.add_dependency "haml-rails", ">= 3.0"
  spec.add_dependency "image_processing", ">= 1.13"
  spec.add_dependency "importmap-rails", ">= 2.0"
  spec.add_dependency "turbo-rails", ">= 2.0"
  spec.add_dependency "kaminari", ">= 1.2"
  spec.add_dependency "potter"
  spec.add_dependency "pundit", ">= 2.0"
  spec.add_dependency "chronic", ">= 0.10"

  spec.add_dependency "rouge", ">= 4.0"
  spec.add_dependency "faker", ">= 3.0"
end
