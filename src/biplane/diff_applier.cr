module Biplane
  class DiffApplier
    def initialize(@client : KongClient)
    end

    def apply(diff : Hash)
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
        @client.destroy(diff)
      when :added
        @client.create(diff)
      when :changed
        if diff.root?
          @client.update(diff as Diff)
        else
          puts diff.roots
          @client.update(diff.roots[0] as Config, diff.roots[1] as Model)
        end
      end
    end
  end
end
