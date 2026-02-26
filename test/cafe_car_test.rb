require "test_helper"

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
end
