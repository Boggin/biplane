require "json"
require "./mixins/*"

module Biplane
  module Model(T)
    include Mixins::Parseable

    property! client

    macro def member_key : Symbol
      :{{ @type.name.split("::").last.downcase }}
    end

    def member_route
      params = {child_key => lookup_key, id: id}
      params[parent.not_nil!.child_key] = parent.not_nil!.lookup_key unless parent.nil?

      Router.build(member_key, params)
    end

    macro diff_attrs(*attrs)
      def diff(other : {{T}}Config)
        {
        {% for attr in attrs %}
          "{{attr}}": compare({{attr}}, other.{{attr}}, other),
        {% end %}
        }.reject {|k, v| v.nil? }
      end

      def ==(other : {{T}}Config)
        diff(other).empty?
      end
    end

    def diff(other : Nil)
      Diff.new(nil, self)
    end

    def compare(server : ChildCollection, local : ChildCollection | Array, other : Config)
      server.diff(local) unless server == local
    end

    # diffing nested info
    def compare(server : Hash, local : Hash, other : Config)
      res = server.reduce(Hash(String, Diff).new) do |memo, k, v|
        lhs = local.fetch(k, nil)
        memo[k] = Diff.new(lhs, v, [other, self]) unless v == lhs
        memo
      end

      res.empty? ? nil : res
    end

    def compare(server, local, other : Config)
      Diff.new(local, server, [other, self]) unless server == local
    end
  end
end
