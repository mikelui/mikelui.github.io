module Jekyll
  module Colorize
    def colorize(input, color)
      %(<span class="text-#{color}" markdown="span">#{input}</span>)
    end
    def colorize_red(input)
      colorize(input, 'red')
    end
    def colorize_blue(input)
      colorize(input, 'blue')
    end
    def colorize_green(input)
      colorize(input, 'green')
    end
  end
end

Liquid::Template.register_filter(Jekyll::Colorize)
