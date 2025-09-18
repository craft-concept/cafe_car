module CafeCar
  module ProcHelpers
    def call_procs!(options, ...)
      options.each do |k, v|
        options[k] = v.call(...) if v.respond_to? :call
      end
    end
  end
end
