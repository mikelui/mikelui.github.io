// TODO init only if sufficient screen size, will need to register a resize event callback, too
// https://github.com/cferdinandi/gumshoe/pull/74

// Custom collapse show assuming specific DOM layout.
// Only one level of collapsing:
//
// nav
//  ul
//    li
//    li
//      div.ml-collapse <-- we're tweaking this
//        ul
//          li
//          li
//    li
//    li
//
// This further assumes that there's only margins on one side of li's
// Otherwise, when we shrink our .ml-collapse, there won't be the expected margin collapsing
//
// IMPORTANT! this is tightly coupled with the accompanying side-nav.scss.
// Make sure they are in sync.
// TODO scope css an js values together. CSS modules, some other framework, et al.

if( $(window).width() > 992 )
{

/* From Modernizr */
function whichTransitionEvent(){
    var t;
    var el = document.createElement('fakeelement');
    var transitions = {
      'transition':'transitionend',
      'OTransition':'oTransitionEnd',
      'MozTransition':'transitionend',
      'WebkitTransition':'webkitTransitionEnd'
    }

    for(t in transitions){
        if( el.style[t] !== undefined ){
            return transitions[t];
        }
    }
}


/* Listen for a transition! */
var transitionEvent = whichTransitionEvent();

function mlshow($elem) {
  $elem.addClass('show');
  $elem.css('height', $elem.find('ul').height());
}

transitionEvent && $('.collapsible-sibling').on(transitionEvent, function(event) {
	if ($(this).hasClass('show')) {
		$(this).css('overflow', 'visible');
	}
	else {
  	$(this).css('overflow', 'hidden');
	}
});


function mlhide($elem) {
  $elem.removeClass('show');
  $elem.css('overflow', 'hidden');
  $elem.css('height', 0);
}

function getSiblingCollapse(elem) {
  var sibling = elem.nextElementSibling;
  var siblingCollapse = sibling ? sibling.className.includes('collapsible-sibling') ? sibling : null : null;
  return siblingCollapse;
}

function getElemCollapse(elem) {
  // if we activated a nav item that has a collapse
  // XXX is this useful anymore?
  var elemCollapse = elem.querySelector('.ml-collapse');
  return elemCollapse;
}

function getParentCollapse(elem) {
  // if we activated a nav item that's inside a collapse
  var parCollapse = elem.closest('[data-gumshoe] .ml-collapse');
  return parCollapse;
}

$('#sidenav > ul[data-gumshoe]').hover(
  function () {
    var collapsibles = this.querySelectorAll('.ml-collapse');
    collapsibles.forEach(e => mlshow($(e)));
  },
  function () {
    // Make sure we don't close the current nav we're in
    // Find the collapsible the nav is in, if any
    // Then remove it from the list of all collapsibles

    var nav = gumshoe.getCurrentNav();
    var collapsibles = Array.from(this.querySelectorAll('.ml-collapse'));

    if (nav && nav.parent) {
      collapse = getElemCollapse(nav.parent) || getParentCollapse(nav.parent) || getSiblingCollapse(nav.parent);
      if (collapse) {
        collapsibles = collapsibles.filter(e => !(e.getAttribute('id') === collapse.getAttribute('id')));
      }
    }
    collapsibles.forEach(e => mlhide($(e)));
});



// custom function to [un]collapse with gumshoe scrollspy
function _checkCollapse () {
  var $lastCollapse = null;

  function __checkCollapse (parent) {
    // if we activated a nav item that has a next-sibling collapsible
    // NB: we do this because of a 'hover' hack that requires an
    // element that would normally be a child, to be a sibling

    collapse = getElemCollapse(parent) || getParentCollapse(parent) || getSiblingCollapse(parent);
    $collapse = $(collapse);

    // if anything to do
    if (collapse) {
      mlshow($collapse);
    }

    if ($lastCollapse) {
      if (!collapse) {
        // if no longer collapsed
        mlhide($lastCollapse);
      }
      else if ($collapse.attr('id') != $lastCollapse.attr('id')) {
        // different collapse
        mlhide($lastCollapse);
      }
    }

    $lastCollapse = $collapse;
  }

  return __checkCollapse;
}
var checkCollapse = _checkCollapse();

function gumshoeCallback (nav) {
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

gumshoe.init({
  offset: ($(window).height() * 0.4),
  callback: gumshoeCallback });

window.addEventListener('resize', function () {
  // recalculate distances
  // automatically calls gumshow.destroy()
  gumshoe.init({
    offset: ($(window).height() * 0.4),
    callback: gumshoeCallback });
});

//----------------------------------------------------------------------------
// HACKS! YAY!

// Manually set widths as a hack because of: https://stackoverflow.com/a/6433475/1371191
// Need to set width of SECOND level manually to avoid getting cut off on the x-axis from overflow: hidden
// Need to set width of FIRST level manually to make sure it's not expanded by second level width
var $mainUl = $('#sidenav > ul');
$mainUl.css('width', $mainUl.find('li').outerWidth(true));

var $collapseSib = $('div.collapsible-sibling');
$collapseSib.css('width', $collapseSib.find('ul').outerWidth(true) * 1.2);

// Manually resize a tooltip if it spills over into the main content
// Can't figure out a way to do this with pure html and css that makes sense
// Tried using overflow-wrap: break-word, but that causes the word to break on every
// letter in combination with position: absolute, and width: auto.
// We could set a constant width for all tooltips, but I prefer the look of dynamically
// sized tooltips.
//
// Here we manually shrink, by setting a width and breaking on a word, if any of the tooltips
// are too wide. Kind of a pain but not too much processing, and it's only done once.

var $postDiv = $('body > .container > .row > div'); // main div with all post text
var padding = parseInt($postDiv.css('padding-left'), 10);
var leftEdge = $postDiv.offset().left + padding;

var $tooltips = $('.dot-tooltip-wrapper');
$tooltips.each(function (idx) {
  $t = $(this)
  $text = $t.find('.dot-tooltip')

  w = $text.width()
  rightEdge = $t.offset().left + w;
  overlap = rightEdge - leftEdge;

  if (overlap > 0) {
    $text.css('width', w - overlap);
    $text.css('overflow-wrap', 'break-word');
  }
});

} // end if width > 992
