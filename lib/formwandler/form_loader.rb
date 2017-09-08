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
      form_instance = form_class.new(models: {inferred_resource_name.to_sym => instance_variable_get("@#{inferred_resource_name}")}, controller: self)
      instance_variable_set("@#{form_instance_name}", form_instance)
    end

    def form_class_name
      "#{inferred_resource_name}_form".camelize
    end

    def form_class
      form_class_name.constantize
    end

    def form_instance_name
      form_class_name.underscore
    end

    def inferred_resource_name
      controller_name.singularize
    end
  end
end
