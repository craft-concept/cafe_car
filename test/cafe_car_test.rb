require "test_helper"
require "minitest/mock"

class CafeCarTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert CafeCar::VERSION
  end

  test "eager load" do
    begin
      Zeitwerk::Loader.eager_load_all
    rescue Zeitwerk::NameError => e
      flunk e.message
    else
      assert CafeCar
    end
  end

  test "haml is a renderer only — host generators keep their template engine" do
    assert_kind_of Haml::RailsTemplate, ActionView::Template.handler_for_extension(:haml)
    assert_not_equal :haml, Rails.application.config.app_generators.options[:rails][:template_engine]
  end

  test "user_class defaults to User and is configurable" do
    assert_equal User, CafeCar.user_class

    CafeCar.stub :user_class_name, "Article" do
      assert_equal Article, CafeCar.user_class
    end
  end

  test "sessions_available? reflects the sessions table" do
    assert CafeCar.sessions_available?, "dummy app has a sessions table"

    CafeCar[:Session].stub :table_exists?, false do
      assert_not CafeCar.sessions_available?
    end
  end
end
