module Biplane
  class PluginConfig
    include Config(self)
    include Mixins::YamlToHash
    include Mixins::Nested
    include Mixins::FlatFormatter

    child_key name
    getter! parsed_attrs

    YAML.mapping({
      name:       String,
      attributes: {type: Hash(String, YAML::Any), nilable: true},
    })

    def attributes
      @parsed_attrs ||= @attributes.nil? ? Hash(String, Type).new : to_hash(@attributes) as Hash
    end

    def as_params
      params = Hash(String, ValueTypes).new
      params["name"] = name
      params.merge! flatten("config", attributes["config"])
    end

    def serialize
      serial = Hash(String, Type).new
      serial["name"] = name
      serial["attributes"] = attributes.not_nil! unless attributes.empty?

      serial
    end
  end
end
