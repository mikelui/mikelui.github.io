---
published: true
layout: post
title: "Creating an Accordion Plugin for Jekyll"
subtitle: "Using Nested Liquid Blocks"
date: 2018-07-22T00:00:00.000Z
author: Mike Lui
sidenav: true
---

Let's start this blog off with some straight-forward informative posts.
As I'm still updating the look of this site, which uses the popular [Jekyll][jekyll] static site generation framework,
I thought it would be nice to share some useful tidbits I've learned.
This is the first real post so I apologize in advance for any dissociative identity disorder
exhibited in the tone and writing.
{: .lead}


# Jekyll Plugins
One really useful feature of Jekyll is the ability to extend Jekyll with [plugins][jekyllplugins].
A Jekyll plugin will fall into 1 of 5 categories:

  1. Adding rules for custom generation of static files
  2. Supporting new markdown formats
  3. New commands (which can overlap other categories)
  4. Extending *[Liquid][liquid]* with custom templates, and
  5. Adding build hooks like post-processing the final rendered HTML.

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

If we add this brute force, we'll have the following plastered in each post using an accordion (per the Bootstrap example):

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

Not only is this a lot of boilerplate, but we'll also have to make sure that our classes and structure match between
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

This snippet will produce the following:

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

We could actually write an entire post with just custom templates, but that would quickly becomes unwieldy and unnatural.

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
{% endparagraph %}

{% list %}
  {% list-item %}
    not the worst but...
  {% endlist-item %}
  {% list-item %}
    ...okay now this is getting annoying
  {% endlist-item %}
{% endlist %}{% endraw %}
```

There's three types of templates: filters, tags, and blocks.  
 - A *filter* transforms text or is replaced with the value of a {%raw%}`{{ variable | filter }}`{% endraw%}.
 - A *tag* typically does something more complex like use options or {%raw%}`{% create variables %}`{%endraw%} for later use.
 - A *block* is useful for {%raw%}`{% capturing %}`{%endraw%}  blocks of text and transforming them {%raw%}`{% endcapturing %}`{%endraw%}.
 - You can even have {%raw%}`{% nested %}{% blocks %}`{%endraw%} that both process {%raw%}`{% endblocks %}{% endnested %}`{%endraw%} the text.

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

Much better! And no hard-coded HTML.
Now we only have to specify an HTML ID for our accordion--although we can automate this, too, if desired--and a title for each collapsible.
Then, we can put normal markdown for each of our collapsibles.
The HTML for the entire accordion and each collapsible card is generated for us, in one place, for all of our posts.
Cool.

Let's start our accordion block.

---

{% comment %}
{::comment}
[![weirdal](/img/weird_al_O-O.jpg){: .mb-3 .col-sm-5 .float-right style="box-shadow: 0 0 5px"}](https://www.ocregister.com/2016/01/25/without-music-education-weird-al-might-not-be-rocking-an-accordion/)
{:/endcomment}
{% endcomment %}

[![weirdal](/img/weird_al_O-O.jpg){: .shadow-lg style="width:100%; box-shadow:0 0 5px"}](https://www.ocregister.com/2016/01/25/without-music-education-weird-al-might-not-be-rocking-an-accordion/)
{: .col-sm-5 .float-right .mb-sm-0}

I couldn't think of a quirky accordion title, so here's a picture of Weird Al.
(That's actually not true, there were *'Accordion to Jim'*, *'The Sokovia Accordions'*,
*'Honda Accordion'*, *'General Ackbar-rion'*, *'The Siege of Acre-dion'* and others--the others were worse)
{: .clearfix}

O-kay, so moving on, we'll start from the [Jekyll][jekyllplugins] and [Liquid][liquidwiki] tutorials,
leaving comments where we need to fill in code:

``` bash
cd my-jekyll-site
mkdir _plugins
touch _plugins/accordion.rb
```

{% include code-title.html contents="accordion.rb" %}
``` ruby
module Jekyll
  module Tags
    class AccordionTag < Liquid::Block
      def initialize(tag_name, block_options, liquid_options)
        super
        @accordionID = "accordion-#{block_options.strip}"
      end

      def render(context)
        # TODO: 
        #   - add to context:
        #     - accordionID
        #     - initial collapse index
        #   - render accordion HTML
      end
    end
  end
end

Liquid::Template.register_tag('accordion', Jekyll::Tags::AccordionTag)
```

Jekyll loads plugins from the `_plugins` folder, so the first thing to do is put our plugin there.
After that we can create a new `AccordionTag` class that inherits from the `Liquid::Block` class.
Blocks only need to implement 2 methods:
 - `initialize` is called when we encounter the `{%raw%}{% accordion my-accordion-id %}{%endraw%}` tag.
Anything that comes directly after `accordion` (e.g. *"my-accordion-id"*) is passed in via the second argument.
We strip the leading and trailing white space off of it and save it to an instance variable so we can use later when
we *render* the entire block.
Note that we need to call `super` first to let Liquid handle any book-keeping (mostly setting some instance variables).
 - `render` is where the fun happens. We're given one argument, `context`, which is just a handle to the environment
that needs to be rendered. This includes any assigned variables and all local and global Jekyll data.
**Here we have to return a string** that will be output from our block and put into our document.
I've added in our `TODO` list in the comments.

We need to add our `@accordionID` to our context handle and initialize an index for our collapsibles,
so they can identity which accordion to target and give themselves an ID.
After that we return the final HTML as a string.

The last bit in this example is to register our block in Liquid's template engine. The string we pass in, '*accordion*',
will be used to create our `AccordionTag` class when parsing the block.

## Nested Liquid Blocks

Before we go any further, we should cover how Liquid handles nesting.
Let's look at our target syntax again:

``` liquid
{% raw %}{% accordion a-unique-id %}
  {% collapsible Title of a Collapsible %}
    stuff
  {% endcollapsible %}

  {% collapsible A Second Collapsible %}
    more stuff
  {% endcollapsible %}

  {% collapsible Another One? %}
    even more stuff
  {% endcollapsible %}
{% endaccordion %}{% endraw %}
```

Liquid works in multiple passes.
First, when Jekyll initializes an instance of Liquid for our document,
it will parse our document and build up a parse tree of *nodes*.
A node can be a chunk of text, a liquid variable, a block, et al. 
When we reach each `accordion` or `collapsible` node, we `initialize` them.
Later, Jekyll will use that instance to render the document.
Liquid will only call `render` on the *root* node, which will try to invoke `render` on all its children, and so on.
A simple chunk of text will be rendered unmodified, while a block node will call its own `render` implementation.
After Jekyll runs Liquid on our document, the markdown processor will finish formatting it to HTML.

Eventually, we'll traverse all the nodes and reach our `accordion` block.
This block will probably have some child `collapsible` nodes which will have to render, too.
*"But how do we get to those child nodes?"* you may ask. Ha-ha, good question, Johnny.
It's quite simple: our base class' render implementation will invoke `render` on any child nodes
and return the resulting text, **including any content inside our block**.

## Render unto Caesar

If we just want to return what's inside of our block, without any further formatting, we can write:

``` ruby
def render(context)
  super
end
```

Why do I bring this up *now*?
Well this means that our `context` variable is going to get passed down to all of our child (collapsible) blocks.
Repeating from earlier, we need to add our `@accordionID` to our context handle and initialize an index for our collapsibles,
so they can identity which accordion to target and give themselves an ID.
Our `context` is a `Liquid::Context` and acts like glorified hash[^1].
To add the `@accordionID` and collapse index, we can do something straightforward like this:

[^1]: The `context` parameter is a Liquid::Context has some additional functionality in addition to 
      just accessing template variables. Accessing Jekyll site level data is arguably the most useful feature for us.
      For example, we can access our site's name with `context["site.title"]`.
      You can even search hashmaps and arrays: `context["site.mydict['mykey'][0]"]`. Neat, huh?

``` ruby
def render(context)
  context["accordionID"] = @accordionID
  context["collapsed_idx"] = 1
  super
end
```

When the collapsibles go to render themselves, they'll pull out those values and everything will be fine.  
Yep.  
That's it.  
Buuuut--what if we decide to nest multiple accordions?
In that case, each accordion level will be overwriting the data from the previous levels.
We have to save the data from the previous level, and restore after calling `super`, in essence creating a new scope
at every nesting level.
Ack! That sounds annoying.
Good thing the Liquid team built this machinery for us!
We can manage a context *stack* as so:

``` ruby
def render(context)
  context.stack do
    context["accordionID"] = @accordionID
    context["collapsed_idx"] = 1
    @content = super
  end
end
```

Each new accordion level creates a new scope, and *contexts* have a custom implementation of `[]` to search up the stack for a matching value.
After we're done, the stack is automatically popped so upper levels never see any of our data. Nice.
The last bit we add is saving the resulting output of our block contents to an instance variable so we can access it outside of the stack scope.

O-kay, now we can get this show on the road.
We know that all our accordion does is wrap up our content in a single div:

``` ruby
def render(context)
  context.stack do
    context["accordionID"] = @accordionID
    context["collapsed_idx"] = 1
    @content = super
  end
  output = %(<div class="accordion" id="#{@accordionID}">#{@content}</div>)

  output
end
```

And we're all done for our accordion! Let's look at our collapsible:

{% include code-title.html contents="collapsible.rb" %}
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
        #   - need to get accordionID
        #   - need to get collapse index
        #   - generate collapsible card HTML
      end
    end
  end
end

Liquid::Template.register_tag('collapsible', Jekyll::Tags::CollapseTag)
```

We start off the same way we did for our accordion.
First, we get the `@title` for our collapsible from the options during initialization.
Then, when we go to `render` our collapsible, we note that we need to get the accordion ID
and an index from our context. *Easy-peasy lemon-squeezy*:

``` ruby
def render(context)
  accordionID = context["accordionID"]
  idx = context["collapsed_idx"]
  collapsedID = "#{accordionID}-collapse-#{idx}"
  headingID = "#{accordionID}-heading-#{idx}"

  # increment for the next collapsible
  context["collapsed_idx"] = idx + 1

  content = super
  # generate collapsible card HTML
end
```

We access the `accordionID` and `collapsed_idx` set by our parent accordion and make unique ID's from them.
We increment the value of `context["collapsed_idx"]` for all the following collapsibles.
This works because all the blocks in the same scope (inside our accordion) share the same context.
We also get the contents of our block with `super`.
Because we're not changing the `context`, there's no need to push the context stack as with the accordion.
Now let's add the collapsible HTML:

``` ruby
def render(context)
  accordionID = context["accordionID"]
  idx = context["collapsed_idx"]
  collapsedID = "#{accordionID}-collapse-#{idx}"
  headingID = "#{accordionID}-heading-#{idx}"

  # increment for the next collapsible
  context["collapsed_idx"] = idx + 1

  content = super
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

This looks pretty good, but we're going to run into one big problem.
Usually markdown processors will not process anything inside HTML tags.
None of the markdown inside our collapsible blocks will get rendered in our final rendered document!
*Heavens to Betsy!*

There are two options to get our content processed as markdown.
The first option is slightly more laborious but is agnostic of the markdown processor.
The second option may feel slightly cleaner for small amounts of HTML, but needs support from the markdown processor.

---

For the first method, we manually call the markdown converter from our Liquid plugin.

{% include code-title.html contents="manual-markdown.rb" %}
``` ruby
def render(context)
  site = context.registers[:site]
  converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
  content = converter.convert(super)

  output = <<~EOS
    <div>
      #{content}
    </div>
  EOS

  output
end
```

*Huh?*
When Jekyll runs the Liquid template engine, it passes in a default context that has some global data already set.
Jekyll's global configuration is accessed via its `site` variable,
and we grab the markdown converter Jekyll is using for ourselves.
Note that `registers` is more like the *guts* of the context that templates won't normally use.

---

For the second method, we just add an [extra attribute to the parent tag](https://kramdown.gettalong.org/syntax.html#html-blocks) of our `content`.

{% include code-title.html contents="markdown-html-attributes.rb" %}
``` ruby
def render(context)
  content = super

  output = <<~EOS
    <div markdown="block">
      #{content}
    </div>
  EOS

  output
end
```

---

I chose to use the first method because I find it more clear when the content is buried in multiple levels of tags.
Without further ado, our final plugins:

{% include code-title.html contents="accordion.rb" %}
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
          @content = super
        end
        output = %(<div class="accordion" id="#{@accordionID}">#{@content}</div>)

        output
      end
    end
  end
end

Liquid::Template.register_tag('accordion', Jekyll::Tags::AccordionTag)
```

{% include code-title.html contents="collapsible.rb" %}
``` ruby
module Jekyll
  module Tags
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
        content = converter.convert(super)

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

Liquid::Template.register_tag('collapsible', Jekyll::Tags::CollapseTag)
```

That's it!
Don't forget to add some error checking or sane defaults for block options.
Try making your own plugins when you find yourself adding in a lot of HTML.


[jekyll]: https://jekyllrb.com/
[jekyllplugins]: https://jekyllrb.com/docs/plugins/
[liquid]: https://help.shopify.com/en/themes/liquid
[liquidwiki]: https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers
[vhdl-guide]: /guides/VHDL-basics
[accordion]: https://getbootstrap.com/docs/4.1/components/collapse/#accordion-example
[wadlers]: https://wiki.haskell.org/Wadler%27s_Law
