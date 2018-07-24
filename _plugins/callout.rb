# Source: https://github.com/heimrichhannot/bootstrap/blob/master/_plugins/callout.rb
# Source: https://stackoverflow.com/questions/19169849/how-to-get-markdown-processed-content-in-jekyll-tag-plugin

module Jekyll
  module Tags
    class CalloutTag < Liquid::Block

      def initialize(tag_name, type, tokens)
        super
        type.strip!
        if %w(primary success info danger warning).include?(type)
          @type = type
        else
          puts "#{type} callout not supported. Defaulting to default"
          @type = "default"
        end
      end

      def render(context)
        output = <<~EOS
                   <div markdown="block" class="bs-callout bs-callout-#{@type}">
                     #{super}
                   </div>
                 EOS

        output
      end
    end
  end
end

Liquid::Template.register_tag('callout', Jekyll::Tags::CalloutTag)
