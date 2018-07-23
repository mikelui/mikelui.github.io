---
published: true
layout: post
title: "Creating an Accordion Plugin for Jekyll"
subtitle: "Using Nested Liquid Blocks"
date: 2018-07-22T00:00:00.000Z
author: Mike Lui
---

Let's start this blog off with some straight-forward informative posts.
As I'm still updating the look of this site, which uses the popular [Jekyll][jekyll] static site generation framework,
I thought it would be nice to share some useful tidbits I've learned.
Since this is the first real post, I apologize in advance for any dissociative identity disorder
exhibited in the tone and writing.
{: .lead}


# Jekyll Plugins
One really useful feature of Jekyll is the ability to extend Jekyll with [plugins][jekyllplugins].
A Jekyll plugin will fall into 1 of 5 categories:

  1. Adding rules for custom generation of static files
  2. Supporting new markdown formats
  3. New commands (which could overlap other categories)
  4. Extending *[Liquid][liquid]* with custom templates, and
  5. Adding build hooks, e.g. generating a new page only after a new collection is rendered to HTML.

This post is about #**4**.
If you find yourself feeling icky putting HTML in your markdown more than a few times, then read on.


---
# Liquid Tags

Jekyll has a [nice little tutorial][jekyllplugins] on adding Liquid tags and filters to Jekyll.
The [GitHub Liquid wiki][liquidwiki] has a slightly more in depth tutorial with more examples.
If you're interested in anything more in-depth, you'll have to either browse the source code or
find some other kind soul's post (*ahem*).

This is a story about adding a [Bootstrap-style accordion][accordion] to the more [friendly VHDL guide][vhdl-guide]
I'm writing for Drexel University's introductory digital logic design course.
I liked the ability to open and close different explanatory sections, to keep text close to code snippets.
Apparently, accordion blocks are not common enough in markdown (at least in *kramdown*) to warrant
specific markdown syntax. Who'da thunk?

If we wanted to add this brute force, we'd have the following plastered in each post using an accordion (per the Bootstrap example):

```html
<div class="accordion" id="myaccordion">

  <div class="card">
    <div class="card-header" id="headingOne">
      <h5 class="mb-0">
        <button class="btn btn-link" type="button" data-toggle="collapse" data-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
          Collapse Title
        </button>
      </h5>
    </div>
    <div id="collapseOne" class="collapse" aria-labelledby="headingOne" data-parent="#myaccordion">
      <div class="card-body">
        Collapsible content
      </div>
    </div>
  </div>

  <!--
    ...
  -->

  <div class="card">
    <div class="card-header" id="headingN">
      <h5 class="mb-0">
        <button class="btn btn-link collapsed" type="button" data-toggle="collapse" data-target="#collapseN" aria-expanded="false" aria-controls="collapseN">
          Another Collapse Title
        </button>
      </h5>
    </div>
    <div id="collapseN" class="collapse" aria-labelledby="headingN" data-parent="#myaccordion">
      <div class="card-body">
        More collapsible content
      </div>
    </div>
  </div>

</div>
```

#### Yuck.

Not only is this a lot of boilerplate, but we'd also have to make sure that our classes and structure match between
all of our posts. A small change to our site's stylesheets could silently break some of our old posts!

There are two ways to address this: 1) we can create our own markdown syntax for this and extend an existing markdown converter,
or 2) add custom templates to generate the HTML.
I opted for adding *custom templates*.
This was partly because I don't want to expend the mental effort to plan and implement a sufficiently natural and robust syntax,
and partly because my future self would end up getting into an [argument][wadlers] with my former self about his design choices.
Templates are also more immediately clear about their intent.

{% callout primary %}
#### Liquid Templates Overview
Liquid templates look something like this:

``` liquid
{% raw %}{% capture lowercase %}
  {{ "UPPERCASE?" | downcase }}
{% endcapture %}

{% assign my_enemies_list = address_book | where: "im_over_it", "false" %}

# A markdown header

A normal paragraph.
This is actually lowercase: {{ lowercase }}

Another normal paragraph about my friends: {{ my_enemies_list | join: ", " }}.{% endraw %}
```

This snippet would produce the following:

---
### A markdown header

{% capture lowercase %}
  {{ "UPPERCASE?" | downcase }}
{% endcapture %}
A normal paragraph.
This is actually lowercase: {{ lowercase }}

{% assign my_enemies_list = address_book | where: "im_over_it", "false" %}
Another normal paragraph about my friends: 😈, 👺, 👻, 👼.

---

If we wanted, we could write the entire post with just custom templates, but this quickly becomes unwieldy and unnatural:

``` liquid
{% raw %}{{ "A markdown header" | headerize }}

{% paragraph %}
  A normal paragraph.
{% endparagraph %}

{% paragraph %}
  This is actually lowercase: {{ "UPPERCASE?" | downcase }}
{% endparagraph %}

{% assign my_enemies_list = address_book | where: "im_over_it", "false" %}
{% paragraph %}
  Another normal paragraph about my friends: {{ my_enemies_list | join: ", " }}.
{% endparagraph %}{% endraw %}
```

There's three types of templates: filters, tags, and blocks.  
 - A *filter* {%raw%}`{{ "tranforms text" | upcase }}`{%endraw%} or is replaced with the value of a `{{ "{{" }} variable }}`.  
 - A *tag* {%raw%}`{% typically does something %}`{%endraw%} more complex like create variables for later use.  
 - A *block* {%raw%}`{% is %} useful for capturing {% endis %}`{%endraw%} blocks of text and transforming them.
 - You could even have {%raw%}`{% nested %}{% blocks %} that both process {% endblocks %}{% endnested %}`{%endraw%} the text.

{% endcallout %}

---
# Custom Liquid Blocks

Continuing our story, we decide to use templates to add an accordion into our post.
There are multiple levels in our accordion (the accordion itself, and then each card inside the accordion)
so it makes sense to use liquid blocks here.
I want to write something like the following:

``` liquid
{% raw %}{% accordion a-unique-id %}
  {% collapsible Title of a Collapsible %}
    First collapsible content.
  {% endcollapsible %}

  {% collapsible A Second Collapsible %}
    # Second

    collapsible content
  {% endcollapsible %}

  {% collapsible Another One? %}
    Third collapsible content.
    1. Which
    2. is
    3. markdown
  {% endcollapsible %}
{% endaccordion %}{% endraw %}
```

Much better!
Now we only have to specify an HTML ID for our accordion--although we could automate this as well if desired--and a title for each collapsible.
Then, we can put normal markdown for each of our collapsibles.
The HTML for the entire accordion and each collapsible card is generated for us, in one place, for all of our posts.
Cool.

Starting from the inside out, let's create a custom `collapsible` block.
We'll start from the [Jekyll][jekyllplugins] and [Liquid][liquidwiki] tutorials,
leaving comments where we need to fill in code:

``` bash
cd my-jekyll-site
mkdir _plugins  # if it doesn't exist
touch _plugins/collapseblock.rb
```

``` ruby
module Jekyll
  module Tags
    class CollapseTag < Liquid::Block
      def initialize(tag_name, block_options, liquid_options)
        super
        @title = block_options.strip
      end

      def render(context)
        # TODO
        # !!! need to get accordionID
        # !!! need to get collapse index
        # !!! generate collapsible card HTML
      end
    end
  end
end

Liquid::Template.register_tag('collapsible', Jekyll::Tags::CollapseTag)
```

Jekyll loads plugins from the `_plugins` folder, so the first thing to do is put our plugin there.
After that we can create a new `CollapseTag` class that inherits from the `Liquid::Block` class.
Blocks only need to implement 2 methods:
 - `initialize` is called when we encounter the `{%raw%}{% collapsible A Title %}{%endraw%}` tag.
Anything that comes directly after `collapsible` ("*A Title*" in this case) is passed in via the second argument.
We strip the leading and trailing white space off of it and save it to an instance variable so we can use later when
we *render* the entire block.
Note that we need to call `super` first to let Liquid handle any book-keeping (mostly setting some instance variables).
 - `render` is where the fun happens. We're given one argument, `context`, which is just a handle to the environment
that needs to be rendered. This includes any assigned variables and all local and global Jekyll data.
I've added in our **TODO** list in the comments.
To create our collapsible HTML, we need to ID of our accordion and a unique ID for this collapsible.
We'll generate a simple hash from the accordion ID and an collapsible index value.

The last bit in this example is the register our block in Liquid's template engine. The string we pass in, '*collapsible*',
will be used to call our `CollapseTag` parsing the block.

## Render unto Caesar

If we want to just output the block's text doing any modifications, we could just do:

``` ruby
def render(context)
  super(context)
end
```

The ancestor classes will handle any extra complexity.
For example, if there are additional nested blocks (*hint-hint wink-wink*), those blocks will get processed first,
and hand the resulting text back to us.
Because the text is going to be markdown, we'll start by converting the markdown to HTML.

``` ruby
def render(context)
  site = context.registers[:site]
  converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
  content = converter.convert(super(context))
  content
end
```

Wuh-What the devil just happened?
When Jekyll runs the Liquid template engine, it passes in a default context that has some global data already set.
Jekyll's global configuration is accessed via its `site` variable.
We grab the markdown converter Jekyll uses and use it ourselves.

Note that `registers` is more like the *guts* of the context that templates wouldn't use.
We can access other environmental variables more naturally with `context["my_variable"]`.

Cool. Let's make the HTML for--*wait, wait, wait*--we're missing something.
Ack! We need to get the accordion and collapsible IDs!
Well, let's just assume some nice fellow put them into our `context` handle.

``` ruby
def render(context)
  accordionID = context["accordionID"]
  idx = context["collapsed_idx"]
  collapsedID = "#{accordionID}-collapse-#{idx}"
  headingID = "#{accordionID}-heading-#{idx}"

  # increment for the next collapsible
  context["collapsed_idx"] = idx + 1

  site = context.registers[:site]
  converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
  content = converter.convert(super(context))
  content
end
```

We retrieved the accordion ID and created IDs for our collapsible.
We also increment the index for the next collapsible and write it back to the context.
This works because all blocks in the same scope (inside our accordion) share the same context.
O-kay, now we can get this show on the road:

``` ruby
def render(context)
  accordionID = context["accordionID"]
  idx = context["collapsed_idx"]
  collapsedID = "#{accordionID}-collapse-#{idx}"
  headingID = "#{accordionID}-heading-#{idx}"

  # increment for the next collapsible
  context["collapsed_idx"] = idx + 1

  site = context.registers[:site]
  converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
  content = converter.convert(super(context))

  output = <<~EOS
    <div class="card">
      <div class="card-header" id="#{headingID}">
        <h4 class="mb-0">
          <button class="btn btn-link collapsed" data-toggle="collapse" data-target="##{collapsedID}" aria-expanded="false" aria-controls="#{collapsedID}">
            <span class="plus-minus-wrapper"><div class="plus-minus"></div></span><span class="collapse-title">#{@title}</span>
          </button>
        </h4>
      </div>
      <div id="#{collapsedID}" class="collapse" aria-labelledby="#{headingID}" data-parent="##{accordionID}">
        <div class="card-body">#{content}</div>
      </div>
    </div>
  EOS

  output
end
```

Yay! This matches the Bootstrap example from earlier.
You can see where we're plugging in the `@title` we saved during the initial tag parse
and the `content` goes in the main card body.

That's all for our collapsible. Let's implement the external `{%raw%}{% accordion %}{% endaccordion %}{%endraw%}` block.

---

[![weirdal](/img/weird_al_O-O.jpg){: width="100%"}](https://www.ocregister.com/2016/01/25/without-music-education-weird-al-might-not-be-rocking-an-accordion/)

I couldn't think of a quirky accordion title, so here's a picture of Weird Al.
(That's actually not true, there were '*Accordion to Jim*', '*The Sokovia Accordions*',
'*Honda Accordion*', '*General Ackbar-rion*', '*The Siege of Acre-dion*' and others--the others were worse)

O-kay, so moving on, our accordion block will start off similar to our collapsible block:

``` ruby
module Jekyll
  module Tags
    class AccordionTag < Liquid::Block
      def initialize(tag_name, block_options, liquid_options)
        super
        @accordionID = "accordion-#{block_options.strip}"
      end

      def render(context)
        # TODO -- add to content:
        #  - accordionID
        #  - initial collapse index
        # render accordion HTML
      end
    end
  end
end

Liquid::Template.register_tag('accordion', Jekyll::Tags::AccordionTag)
```

To add the `@accordionID` and collapse index, we could do something straightforward like this:

``` ruby
def render(context)
  context["accordionID"] = @accordionID
  context["collapsed_idx"] = 1
  # render accordion HTML
end
```

The collapsibles would receive this data and this works fine.  
Yep.  
That's it.  
Buuuut--let's make sure this works for weird cases, like if we decide to nest multiple accordions.
In such a case, each accordion level would be overwriting the data from the previous levels.
We need to create a new scope for each nesting level.
Good thing the Liquid team built this machinery for us!
We can manage a context *stack* as so:

``` ruby
def render(context)
  context.stack do
    context["accordionID"] = @accordionID
    context["collapsed_idx"] = 1
    # render accordion HTML
  end
end
```

Each new accordion creates a new scope, and *contexts* have a custom implementation of `[]` to search up the stack for a matching value.
Now just to take care of this last bit of HTML:

``` ruby
def render(context)
  context.stack do
    context["accordionID"] = @accordionID
    context["collapsed_idx"] = 1
    output = "<div class=\"accordion\" id=\"#{@accordionID}\">#{super(context)}</div>"
    output
  end
end
```

That's it! Here's the entire plugin. You can try to add some error checking into the accordion ID.

``` ruby
module Jekyll
  module Tags
    class AccordionTag < Liquid::Block

      def initialize(tag_name, block_options, liquid_options)
        super
        @accordionID = "accordion-#{block_options.strip}"
      end

      def render(context)
        context.stack do
          context["accordionID"] = @accordionID
          context["collapsed_idx"] = 1
          output = "<div class=\"accordion\" id=\"#{@accordionID}\">#{super(context)}</div>"
          output
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
      
        # increment for the next collapsible
        context["collapsed_idx"] = idx + 1
      
        site = context.registers[:site]
        converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
        content = converter.convert(super(context))
      
        output = <<~EOS
          <div class="card">
            <div class="card-header" id="#{headingID}">
              <h4 class="mb-0">
                <button class="btn btn-link collapsed" data-toggle="collapse" data-target="##{collapsedID}" aria-expanded="false" aria-controls="#{collapsedID}">
                  <span class="plus-minus-wrapper"><div class="plus-minus"></div></span><span class="collapse-title">#{@title}</span>
                </button>
              </h4>
            </div>
            <div id="#{collapsedID}" class="collapse" aria-labelledby="#{headingID}" data-parent="##{accordionID}">
              <div class="card-body">#{content}</div>
            </div>
          </div>
        EOS
      
        output
      end
    end
  end
end

Liquid::Template.register_tag('accordion', Jekyll::Tags::AccordionTag)
Liquid::Template.register_tag('collapsible', Jekyll::Tags::CollapseTag)
```

[jekyll]: https://jekyllrb.com/
[jekyllplugins]: https://jekyllrb.com/docs/plugins/
[liquid]: https://help.shopify.com/en/themes/liquid
[liquidwiki]: https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers
[vhdl-guide]: /guides/VHDL-basics
[accordion]: https://getbootstrap.com/docs/4.1/components/collapse/#accordion-example
[wadlers]: https://wiki.haskell.org/Wadler%27s_Law
