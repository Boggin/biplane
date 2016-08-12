module Biplane
  class PluginConfig
    include Config(self)
    include Mixins::YamlToHash
    include Mixins::Nested
    include Mixins::NormalizeAttributes
    include Mixins::Timestamps

    child_key name
    getter! parsed_attrs

    YAML.mapping({
      name:       String,
      attributes: {type: Hash(String, YAML::Any), nilable: true},
    })

    def attributes
      @parsed_attrs ||= @attributes.nil? ? Hash(String, Type).new : normalize(to_hash(@attributes) as Hash)
    end

    def as_params
      normalize(attributes, {
        name:       name,
        created_at: pg_now,
      })
    end

    def serialize
      serial = Hash(String, Type).new
      serial["name"] = name
      serial["attributes"] = attributes.not_nil! unless attributes.empty?

      serial
    end
  end
end
