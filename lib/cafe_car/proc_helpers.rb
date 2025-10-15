module CafeCar
  module ProcHelpers
    def call_procs!(options, ...)
      options.each do |k, v|
        options[k] = v.call(...) if v.respond_to? :call
      end
    end

    def clone_or_call!(value, ...)
      value.respond_to?(:call) ? value.call(...) : value.clone
    end
  end
end
