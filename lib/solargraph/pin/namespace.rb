module Solargraph
  module Pin
    class Namespace < Pin::Base
      attr_reader :visibility

      attr_reader :type

      # @return [Pin::Reference]
      attr_reader :superclass_reference

      def initialize location, namespace, name, comments, type, visibility, superclass
        super(location, namespace, name, comments)
        @type = type
        @visibility = visibility
        # @superclass_reference = Reference.new(self, superclass) unless superclass.nil?
        @superclass_reference = Pin::Reference.new(location, namespace, superclass) unless superclass.nil?
      end

      # @return [Array<Pin::Reference>]
      def include_references
        @include_references ||= []
      end

      # @return [Array<String>]
      def extend_references
        @extend_references ||= []
      end

      def kind
        Pin::NAMESPACE
      end

      def context
        @context ||= ComplexType.parse("#{type.to_s.capitalize}<#{path}>")
      end

      def scope
        context.scope
      end

      def completion_item_kind
        (type == :class ? LanguageServer::CompletionItemKinds::CLASS : LanguageServer::CompletionItemKinds::MODULE)
      end

      # @return [Integer]
      def symbol_kind
        (type == :class ? LanguageServer::SymbolKinds::CLASS : LanguageServer::SymbolKinds::MODULE)
      end

      def path
        @path ||= (namespace.empty? ? '' : "#{namespace}::") + name
      end

      def return_complex_type
        @return_complex_type ||= ComplexType.parse( (type == :class ? 'Class' : 'Module') + "<#{path}>" )
      end

      def domains
        @domains ||= begin
          result = []
          directives.each do |d|
            result.push d.tag.text if d.tag.tag_name == 'domain'
          end
          result
        end
      end

      def infer api_map
        # Assuming that namespace pins are always fully qualified
        return_complex_type
      end
    end
  end
end
