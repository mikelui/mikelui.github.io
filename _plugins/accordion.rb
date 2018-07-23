# Added to support Bootstrap accordion collapsing
# Unknown effects if you try to nest multiple accordions
#
# Example:
#
# {% accordion my-html-accordion-id %}
# 
# {% collapse Title of Collapsed Card 1 %}
# Collapsed content
# {% endcollapse %}
#
# {% collapse Title of Collapsed Card 2 %}
# Collapsed content
# {% endcollapse %}
#
# {% endaccordion %}

module Jekyll
  module Tags
    class AccordionTag < Liquid::Block

      def initialize(tag_name, block_options, liquid_options)
        super
        @block_options = block_options.strip
        if @block_options.split(' ').size > 1
          raise Liquid::ArgumentError, "Expecting accordion id - single string - line #{liquid_options.line_number} + front matter"
        end
        @accordionID = "accordion-#{@block_options}"
      end

      def render(context)
        context.stack do
          context["accordionID"] = @accordionID
          context["collapsed_idx"] = 1 # increment on each 'collapse' block
          content = super(context)
          "<div class=\"accordion\" id=\"#{@accordionID}\">#{content}</div>"
        end
      end
    end

    class CollapseTag < Liquid::Block

      def initialize(tag_name, block_options, liquid_options)
        super
        @title = block_options.strip
      end

      def render(context)
        accordionID = context["accordionID"]
        idx = context["collapsed_idx"]
        collapsedID = "#{accordionID}-collapse-#{idx}"
        headingID = "#{accordionID}-heading-#{idx}"
        context["collapsed_idx"] = idx + 1

        site = context.registers[:site]
        converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
        content = converter.convert(super(context))

"<div class=\"card\">
  <div class=\"card-header\" id=\"#{headingID}\">
    <h4 class=\"mb-0\">
      <button class=\"btn btn-link collapsed\" data-toggle=\"collapse\" data-target=\"##{collapsedID}\" aria-expanded=\"false\" aria-controls=\"#{collapsedID}\">
        <span class=\"plus-minus-wrapper\"><div class=\"plus-minus\"></div></span><span class=\"collapse-title\">#{@title}</span>
      </button>
    </h4>
  </div>
  <div id=\"#{collapsedID}\" class=\"collapse\" aria-labelledby=\"#{headingID}\" data-parent=\"##{accordionID}\">
    <div class=\"card-body\">#{content}</div>
  </div>
</div>"
      end
    end

  end
end

Liquid::Template.register_tag('accordion', Jekyll::Tags::AccordionTag)
Liquid::Template.register_tag('collapse', Jekyll::Tags::CollapseTag)
