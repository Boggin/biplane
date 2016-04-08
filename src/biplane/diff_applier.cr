module Biplane
  class DiffApplier
    include Mixins::Paint

    def initialize(@client : KongClient)
    end

    def apply(diff : Hash)
      if diff.empty?
        puts paint("Nothing to apply!", :green)
        exit(0)
      end

      diff.each do |name, diff|
        apply(diff)
      end
    end

    def apply(diff : Nil)
    end

    def apply(diff : Diff)
      return unless diff.changed?

      case diff.state
      when :removed
        @client.destroy(diff) if diff.root?
      when :added
        @client.create(diff) if diff.root?
      when :changed
        if diff.root?
          @client.update(diff as Diff)
        else
          @client.update(diff.roots[0] as Config, diff.roots[1] as Model)
        end
      end
    end
  end
end
