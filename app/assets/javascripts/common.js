// Autocomplete

$(document).on('turbolinks:load', function() {
  $(".auto-source").autocomplete({
    source: $('.auto-source').data('autocomplete-source')
  });
});

// Initializing popovers & tooltips
function initPopovers() {
  var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
  var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
    return new bootstrap.Popover(popoverTriggerEl)
  });
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  });
}

$(document).on('turbolinks:load', function() {
  initPopovers();
});

// In modals
$(document).on('shown.bs.modal', function (event) {
  initPopovers();
});

// Initializing selectpicker
$(document).on('turbolinks:load', function() {
  $('.selectpicker').selectpicker();
});

// Selectpicker to work in modals
$(document).on('shown.bs.modal', function (event) {
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

// Inline edit select form to submit on change
$(document).on('turbolinks:load', function() {
  $('.inline-edit-select').change(function() {
    $(this).closest('form').submit();
  });
});

$(document).on('turbolinks:load', function() {
  $('.inline-edit-input').on('focus', function() {
    $(this).addClass('inline-edit-input-focus');
  });

  $('.inline-edit-input').on('blur', function() {
    $(this).removeClass('inline-edit-input-focus');
    var initialValue = $(this).data('initialValue'); // Retrieve initial value
    if (initialValue !== $(this).val()) { // Compare initial value with current value
      $(this).closest('form').submit();
    }
  });
});

// Select all checkboxes
$(document).on('turbolinks:load', function(e) {
  var $checkboxes = $('.checkbox_selectable');

  function mass_edit_buttons() {
    var countCheckedCheckboxes = $checkboxes.filter(':checked').length;
    if (countCheckedCheckboxes == 0 ) {
      $(".mass_edit_button").prop("disabled", true);
    }
    if (countCheckedCheckboxes != 0) {
      $(".mass_edit_button").prop("disabled", false);
    }
  }

  $checkboxes.change(function(){
    if ($(this).prop('checked') == false) {
      $(".checkbox_select_all").prop('checked', false);
    }
    mass_edit_buttons();
  });

  $(".checkbox_select_all").click(function () {
    $(".checkbox_selectable:visible").prop('checked', $(this).prop('checked'));
    $(".checkbox_selectable:visible").trigger('change'); // Trigger the change event on individual checkboxes
  });
});
