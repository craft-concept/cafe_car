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

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/craft-concept/cafe_car"
  spec.metadata["changelog_uri"] = "https://github.com/craft-concept/cafe_car"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.3.2"
end
