# frozen_string_literal: true

require "cnc/core_ext"

Dir.glob(File.expand_path("core_ext/*.rb", __dir__)).sort.each do |path|
  require path
end
