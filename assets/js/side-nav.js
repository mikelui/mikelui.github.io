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
function mlshow($elem) {
  $elem.addClass('show');
  $elem.css('height', $elem.find('ul').height());
  $elem.css('overflow', 'visible');
}

function mlhide($elem) {
  $elem.removeClass('show');
  $elem.css('height', 0);
  $elem.css('overflow', 'hidden');
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


