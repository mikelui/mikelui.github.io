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
        div['class'] = "collapsible-sibling position-relative collapse";
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

  # TODO init only if sufficient screen size, will need to register a resize event callback, too
  # https://github.com/cferdinandi/gumshoe/pull/74
  html_doc.add_child(<<~EOS
<script>
  function getSiblingCollapse(elem) {
    var sibling = elem.nextElementSibling;
    var siblingCollapse = sibling ? sibling.className.includes('collapsible-sibling') ? sibling : null : null;
    return siblingCollapse;
  }

  function getElemCollapse(elem) {
    // if we activated a nav item that has a collapse
    // XXX is this useful anymore?
    var elemCollapse = elem.querySelector('.collapse');
    return elemCollapse;
  }

  function getParentCollapse(elem) {
    // if we activated a nav item that's inside a collapse
    var parCollapse = elem.closest('[data-gumshoe] .collapse');
    return parCollapse;
  }

  $('#sidenav > ul[data-gumshoe]').hover(
    function () {
      var collapsibles = this.querySelectorAll('.collapse');
      collapsibles.forEach(e => $(e).collapse('show'));
    },
    function () {
      var nav = gumshoe.getCurrentNav();
      var collapsibles = Array.from(this.querySelectorAll('.collapse'));
      if (nav && nav.parent) {
        collapse = getElemCollapse(nav.parent) || getParentCollapse(nav.parent) || getSiblingCollapse(nav.parent);
        if (collapse) {
          collapsibles = collapsibles.filter(e => !(e.getAttribute('id') === collapse.getAttribute('id')));
        }
      }
      collapsibles.forEach(e => $(e).collapse('hide'));
    });

  // custom function to [un]collapse with gumshoe scrollspy
  function _checkCollapse () {
    var lastCollapse = null;

    function __checkCollapse (parent) {
      // if we activated a nav item that has a next-sibling collapsible
      // NB: we do this because of a 'hover' hack that requires an
      // element that would normally be a child, to be a sibling

      collapse = getElemCollapse(parent) || getParentCollapse(parent) || getSiblingCollapse(parent);

      // XXX don't use 'toggle' for collapsing, since multiple
      // gumshoe callbacks can fire on the same scroll when
      // using 'smooth scroll', causing jumping back and forth
      // between collapse states

      // if anything to do
      if (collapse) {
        $(collapse).collapse('show');
      }

      if (lastCollapse) {
        // if no longer collapsed
        if (!collapse) {
          $(lastCollapse).collapse('hide');
        }
        // different collapse
        else if (collapse.getAttribute('id') != lastCollapse.getAttribute('id')) {
          $(lastCollapse).collapse('hide');
        }
      }

      lastCollapse = collapse;
    }

    return __checkCollapse;
  }

  var checkCollapse = _checkCollapse();

  gumshoe.init({
    offset: 100,
  	callback: function (nav) {
      if (!nav) {
        return;
      }

  		// Deactivate any currently active parent
  		var current = document.querySelector('.active-parent');
  		if (current) {
  			current.classList.remove('active-parent');
  		}

  		// Check if the nav link has a parent nav
  		var parNav = nav.parent.closest('[data-gumshoe] > li');

  		// If the nav link has a parent item,
  		// Then add a class to that link
  		if (parNav) {
  			parNav.classList.add('active-parent');
  		}

      checkCollapse(nav.parent);
  	}
});
</script>
                     EOS
                    )
  post.output = html_doc.to_s
end
