// Accessing the clipboard
$(document).on('turbolinks:load', function() {
  var clipboard = new Clipboard('.clipboard-btn');
});

// Initializing popovers & tooltips
$(document).on('turbolinks:load', function() {
  var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
  var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
    return new bootstrap.Popover(popoverTriggerEl)
  })
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  })
});

$(document).on('shown.bs.modal', function (event) {
  var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
  var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
    return new bootstrap.Popover(popoverTriggerEl)
  })
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  })
  $('.selectpicker').selectpicker();
});


// Table sorting by column

$(document).on('turbolinks:load', function() {
  $(function() {
    $("table.sortable").tablesorter({
      imgAttr: 'title' // image attribute used by "image" parser
    });
  });
});

$.tablesorter.addParser({
  id: 'font-awesome',
  is: function(s) {
    return false;
  },
  format: function(s, table, cell) {
    var $cell = $(cell);
    return $cell.html() || s;
  },
  type: 'text'
});
