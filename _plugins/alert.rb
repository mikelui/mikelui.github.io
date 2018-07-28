module Jekyll
  module Tags
    class AlertTag < Liquid::Block

      def initialize(tag_name, type, tokens)
        super
        type.strip!
        if %w(success danger warning info).include?(type)
          @type = type
        else
          puts "#{type} callout not supported. Defaulting to info"
          @type = 'info'
        end
      end

      def render(context)
        icon = case @type
               when 'success'
                 '<i class="fa fa-check-circle"></i> <b>Success:</b>'
               when 'danger'
                 '<i class="fa fa-exclamation-triangle"></i> <b>Danger:</b>'
               when 'warning'
                 '<i class="fa fa-exclamation-circle"></i> <b>Warning:</b>'
               when 'info'
                 '<i class="fa fa-info-circle"></i> <b>Note:</b>'
               end

        # NB! This is a 'span' markdown, so paragraphs will be merged together!
        # Otherwise we'd need to add special CSS to remove the pre- and post-
        # margins added on the div block.
        # It is acceptable to add '<br>'s if you really want the newline.
        output = <<~EOS
                   <div markdown="span" class="alert alert-#{@type}" role="alert">
                     #{icon if icon} #{super}
                   </div>
                 EOS

        output
      end
    end
  end
end

Liquid::Template.register_tag('alert', Jekyll::Tags::AlertTag)
