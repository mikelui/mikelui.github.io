module Jekyll
  module Tags
    class MediaTag < Liquid::Block

      def initialize(tag_name, block_options, liquid_options)
        super
        # config hash from "option1=value option2=value option3=value ..."
        @options = {}
        for kv in block_options.strip.split(' ').map{|kv| kv.split('=')} do
          @options[kv[0]] = kv[1]
        end
      end

      def render(context)
        site = context.registers[:site]
        converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
        content = converter.convert(super(context))

        header = if @options.has_key?('header')
                   <<~EOS
                     <h5 class="mt-0">#{@options['header']}</h5>
                   EOS
                 else
                   nil
                 end

        media_content = if @options['side'] == 'right'
                          <<~EOS
                            <div class="media-body">
                            #{header.strip if header}
                            #{content.strip}
                            </div>
                            <img class="mr-3" src="#{@options['img']}" alt="#{@options['alt']}">
                          EOS
                        else
                          <<~EOS
                            <img class="mr-3" src="#{@options['img']}" alt="#{@options['alt']}">
                            <div class="media-body">
                            #{header.strip if header}
                            #{content.strip}
                            </div>
                          EOS
                        end

        output = <<~EOS
          <div class="media">
          #{media_content.strip}
          </div>
        EOS

        output
      end

    end
  end
end

Liquid::Template.register_tag('media', Jekyll::Tags::MediaTag)
