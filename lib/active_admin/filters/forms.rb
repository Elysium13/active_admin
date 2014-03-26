module ActiveAdmin
  module Filters

    # This form builder defines methods to build filter forms such
    # as the one found in the sidebar of the index page of a standard resource.
    class FormBuilder < ::ActiveAdmin::FormBuilder
      include ::ActiveAdmin::Filters::FormtasticAddons

      def initialize(*args)
        @use_form_buffer = true # force ActiveAdmin::FormBuilder to use the form buffer
        super
      end

      def filter(method, options = {})
        if method.present? && options[:as] ||= default_input_type(method)
          input(method, options)
        end
      end

      protected

      # Returns the default filter type for a given attribute. If you want
      # to use a custom search method, you have to specify the type yourself.
      def default_input_type(method, options = {})
        if method =~ /_(contains|starts_with|ends_with)\z/
          :string
        elsif reflection_for(method) || polymorphic_foreign_type?(method)
          :select
        elsif column = column_for(method)
          case column.type
          when :date, :datetime
            :date_range
          when :string, :text
            :string
          when :integer, :float, :decimal
            :numeric
          when :boolean
            :boolean
          end
        end
      end

      def custom_input_class_name(as)
        "Filter#{as.to_s.camelize}Input"
      end

      def active_admin_input_class_name(as)
        "ActiveAdmin::Inputs::Filter#{as.to_s.camelize}Input"
      end

    end


    # This module is included into the view
    module ViewHelper

      # Helper method to render a filter form
      def active_admin_filters_form_for(search, filters, options = {})
        options[:builder] ||= ActiveAdmin::Filters::FormBuilder
        options[:url] ||= collection_path
        options[:html] ||= {}
        options[:html][:method] = :get
        options[:html][:class] ||= "filter_form"
        options[:as] = :q
        clear_link = link_to(I18n.t('active_admin.clear_filters'), "#", :class => "btn clear_filters_btn")

        form_for search, options do |f|
          filters.group_by{ |o| o[:attribute] }.each do |attribute, array|
            opts     = array.last # grab last-defined `filter` call from DSL
            next if opts.key?(:if)     && !call_method_or_proc_on(self, opts[:if])
            next if opts.key?(:unless) &&  call_method_or_proc_on(self, opts[:unless])

            f.filter attribute, opts.except(:if, :unless)
          end
          buttons = content_tag :div, :class => "btn-group" do
            f.submit(I18n.t('active_admin.filters.buttons.filter')) +
              link_to(I18n.t('active_admin.filters.buttons.clear'), '#', :class => 'btn') +
              hidden_field_tags_for(params, :except => [:q, :page])
          end

          f.form_buffers.last + buttons
        end
      end

    end

  end
end
