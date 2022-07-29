// Accessing the clipboard
$(document).on('turbolinks:load', function() {
  var clipboard = new Clipboard('.clipboard-btn');
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
