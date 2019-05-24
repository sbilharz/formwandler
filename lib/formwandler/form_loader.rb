# frozen_string_literal: true

module Formwandler
  module FormLoader
    extend ActiveSupport::Concern

    class_methods do
      def load_form(opts = {})
        before_action :_formwandler_load_form, opts
      end

      def skip_load_form(opts = {})
        skip_before_action :_formwandler_load_form, opts
      end
    end

    private

    def _formwandler_load_form
      models = opts[:models] || {inferred_resource_name.to_sym => instance_variable_get("@#{inferred_resource_name}")}.compact
      form_instance = form_class.new(models: models, controller: self)
      instance_variable_set("@#{form_instance_name}", form_instance)
    end

    def form_class_name
      "#{namespace}::#{inferred_resource_name.camelize}Form"
    end

    def form_class
      form_class_name.constantize
    end

    def form_instance_name
      "#{inferred_resource_name}_form"
    end

    def namespace
      self.class.name.split('::')[0..-2].join('::')
    end

    def inferred_resource_name
      controller_name.singularize
    end
  end
end
