require_relative "lib/cafe_car/version"

Gem::Specification.new do |spec|
  spec.name        = "cafe_car"
  spec.version     = CafeCar::VERSION
  spec.authors     = ["Jeff Peterson"]
  spec.email       = ["jeff@yak.sh"]
  spec.homepage    = "https://concept.love/cafe_car"
  spec.summary     = "Rails UI and admin panels."
  spec.description = "Rails UI and admin panels."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/craft-concept/cafe_car"
  spec.metadata["changelog_uri"]   = "https://github.com/craft-concept/cafe_car"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails"
  spec.add_dependency "activerecord_where_assoc"
  spec.add_dependency "propshaft"
  spec.add_dependency "haml-rails"
  spec.add_dependency "image_processing"
  spec.add_dependency "importmap-rails"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "kaminari"
  spec.add_dependency "pundit"
  spec.add_dependency "chronic"
  spec.add_dependency "web-console"
end
