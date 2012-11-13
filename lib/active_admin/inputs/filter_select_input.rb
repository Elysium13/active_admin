module ActiveAdmin
  module Inputs
    class FilterSelectInput < ::Formtastic::Inputs::SelectInput
      include FilterBase
      
      def input_name
        "#{super}_in"
      end
      
      def input_options
        super.merge(:include_blank => multiple? ? false : I18n.t('active_admin.any'))
      end
      
      def input_html_options_name_multiple
        "#{object_name}[#{input_name}][]"
      end
      
      def extra_input_html_options
        multiple? ? { :multiple => true, :size => options[:size] } : {}
      end
    end
  end
end