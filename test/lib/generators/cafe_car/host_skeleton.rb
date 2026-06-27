# Builds the minimal host-app files the generators expect to mutate
# (Gemfile, routes, ApplicationController, JS entrypoint) in the generator
# test destination, so injectors have a sentinel to anchor to.
module HostSkeleton
  def build_host_skeleton
    write "Gemfile", <<~RUBY
      source "https://rubygems.org"
    RUBY

    write "config/routes.rb", <<~RUBY
      Rails.application.routes.draw do
      end
    RUBY

    write "app/controllers/application_controller.rb", <<~RUBY
      class ApplicationController < ActionController::Base
      end
    RUBY

    write "app/javascript/application.js", <<~JS
      import "@hotwired/turbo-rails"
    JS
  end

  def write(path, contents)
    full = File.join(destination_root, path)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, contents)
  end
end
