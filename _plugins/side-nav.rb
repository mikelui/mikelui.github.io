require 'nokogiri'

def add_child_nav_item(elem, node, html_doc)
	li = node.add_child(Nokogiri::XML::Node.new 'li', html_doc)

	wrapper = li.add_child(Nokogiri::XML::Node.new 'div', html_doc)
	wrapper['class'] = "dot-tooltip-wrapper"
	div = wrapper.add_child(Nokogiri::XML::Node.new 'div', html_doc)
	div['class'] = "dot-tooltip"
	div.content = elem.content

	a = li.add_child(Nokogiri::XML::Node.new 'a', html_doc)
	a['class'] = "dot"
	a['href'] = "##{elem['id']}"

	li
end

Jekyll::Hooks.register :posts, :post_render do |post, payload|

  # Render a scrollspy-style (https://github.com/cferdinandi/gumshoe) side nav
  next unless post['sidenav'] == true

  html_doc = Nokogiri::HTML::DocumentFragment.parse(post.output)

  # Choose only h1 and h2 tags
  # Don't care about other navs
  # ENHANCMENT make this the default behavior but allow
  # the document to choose tags via front matter
  headers = html_doc.css('h1[id], h2[id]')

  # I don't want one unless there's at least 3 nav components
  next unless headers.length > 2

  # Build up the sidebar, allowing one level of nesting if
  # an h2 tag comes after an h1 tag
  # NB. Assume headers are held in-order as they appear on the page
  sidenav = Nokogiri::XML::Node.new 'nav', html_doc
  sidenav['id'] = "sidenav"

  # TODO media breakpoint
  sidenav['class'] = "col-xl-2 col-lg-2"

  # first level
  topul = sidenav.add_child(Nokogiri::XML::Node.new 'ul', html_doc)
  topul['data-gumshoe'] = ""

  collapsible_idx = 1;

  headers.each do |elem|
    if elem.name == 'h1'
      @li_last = add_child_nav_item(elem, topul, html_doc)

    elsif elem.name == 'h2'
      if (!@li_last.next || !@li_last.next['class'].include?("collapsible-sibling"))
        # Add pseudo second level if it doesn't exist
        # We need to make the next level a sibling instead of a child
        # so that the :hover pseudo-selector only selects one level
        div = Nokogiri::XML::Node.new 'div', html_doc
        div['id'] = "sidenav-collapsible-#{collapsible_idx}"
        div['class'] = "collapsible-sibling position-relative ml-collapse";
        collapsible_idx += 1

        div_border_wrapper = div.add_child(Nokogiri::XML::Node.new 'div', html_doc)
        div_border_wrapper['class'] = "border-wrapper position-absolute d-flex h-100"
        div_border = div_border_wrapper.add_child(Nokogiri::XML::Node.new 'div', html_doc)
        div_border['class'] = "border-left align-self-center"

        @ul_last = div.add_child(Nokogiri::XML::Node.new 'ul', html_doc)
        @ul_last['class'] = "nav dotstyle"

        @li_last.after div
      end

      li = add_child_nav_item(elem, @ul_last, html_doc)

    end
  end

  main_row = html_doc.css('.post > .row')
  raise 'unexpected HTML layout' unless main_row.length == 1
  main_row.first.add_child(sidenav)
  html_doc.add_child('<script src="https://cdnjs.cloudflare.com/ajax/libs/gumshoe/3.5.1/js/gumshoe.min.js"></script>')
  html_doc.add_child('<script src="/assets/js/side-nav.js"></script>')
  post.output = html_doc.to_s
end
