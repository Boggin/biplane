require "crustache"

module Biplane
  class Interpolate
    getter :template

    def self.new(path : String)
      new File.open(path)
    end

    def initialize(io : IO)
      @template = Crustache.parse io.gets_to_end
    end

    # assumes all keys are string
    def apply(context : Hash(String, String))
      Crustache.render(@template, context)
    end

    def save(context, output : IO = STDOUT)
      output << apply(context)
    end
  end
end
