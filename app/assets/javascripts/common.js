// Trigger searchbox
$(document).on('turbolinks:load', function() {
  $('#navbarSearch').on('click', function(event) {
    event.preventDefault(); // Prevent the default link behavior
    $('#searchbox').dropdown('show'); // Trigger the dropdown show method
    $('#searchbox-toggle-container').addClass('bg-dark');
    $('#search').focus();
  });

  $('#search-form').on('ajax:beforeSend', function() {
    $('#searching').removeClass('d-none')
  });
  // Close the dropdown if clicking outside the searchbox or the button
  $(document).on('click', function(event) {
    if (!$(event.target).closest('#navbarSearch, #searchbox').length) {
      $('#searchbox').dropdown('hide');
      $('#searchbox-toggle-container').removeClass('bg-dark');
    }
  });
});

// Toggle visibility
$(document).on('turbolinks:load', function() {
  $('.toggle-visibility').on('click', function() {
      $('.toggle-visibility').toggleClass('d-none');
  });
});

// Autocomplete
function initAutocomplete() {
  $(".auto-source").each(function() {
    var $this = $(this);
    $this.autocomplete({
      minLength: 2,
      source: $this.data('autocomplete-source')
    });
  });
}

$(document).on('turbolinks:load', function() {
  initAutocomplete();
});

// In modals
$(document).on('shown.bs.modal', function (event) {
  initAutocomplete();
});

// cookies management
function setCookie(name, value, days) {
    var date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000)); // 24 hours * 60 minutes * 60 seconds * 1000 ms
    var expires = "expires=" + date.toUTCString();
    document.cookie = name + "=" + JSON.stringify(value) + ";" + expires + ";path=/";
}

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
      headerTemplate : '{icon}{content}',
      cssIconNone: 'bi bi-sort-caret sorter-icon',
      cssIconAsc:  'bi bi-sort-caret-up sorter-icon',
      cssIconDesc: 'bi bi-sort-caret-down sorter-icon',
      imgAttr: 'title', // image attribute used by "image" parser

      textExtraction: function(node) {
          // Replace en dash with hyphen
          return $(node).text().replace(/–/g, '-');
      }
    });
  });
});

$.tablesorter.addParser({
  id: 'bootstrap-icons',
  is: function(s) {
    return false;
  },
  format: function(s, table, cell) {
    var $cell = $(cell);
    return $cell.html() || s;
  },
  type: 'text'
});

// exclusive form fields
$.fn.exclusive_fields =  function() {
  $('.form-exclusive').on('input', function() {
    // Find the nearest input with the class 'form-exclusive' and clear its value
    $(this).closest('.input-group').find('.form-exclusive').not(this).val('');
  });
}

// Initializing exclusive form fields
$(document).on('turbolinks:load', function() {
  $.fn.exclusive_fields();
});

// exclusive form fields to work in modals
$(document).on('shown.bs.modal', function (event) {
  $.fn.exclusive_fields();
});

// Inline edit select form to submit on change

$.fn.inline_listeners = function() {
  $('.inline-edit-select').change(function() {
    $(this).closest('form').submit();
  });

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
}

$(document).on('turbolinks:load', function() {
  $.fn.inline_listeners();
});

$.fn.checkbox_listeners = function() {
  $('.checkbox_selectable').change(function() {
    if ($(".checkbox_selectable:visible:checked").length == $(".checkbox_selectable:visible").length ) {
      $(".checkbox_select_all").prop('checked', true);
    } else {
      $(".checkbox_select_all").prop('checked', false);
    }
    $.fn.mass_edit_buttons();
  });

  $(".checkbox_select_all").click(function () {
    $(".checkbox_selectable:visible").prop('checked', $(this).prop('checked'));
    $(".checkbox_selectable:visible").trigger('change'); // Trigger the change event on individual checkboxes
  });
}

$.fn.mass_edit_buttons = function() {
  var countCheckedCheckboxes = $('.checkbox_selectable').filter(':checked').length;
  if (countCheckedCheckboxes == 0 ) {
    $(".mass_edit_button").prop("disabled", true);
  }
  if (countCheckedCheckboxes != 0) {
    $(".mass_edit_button").prop("disabled", false);
  }
}

// Select all checkboxes
$(document).on('turbolinks:load', function() {
  $.fn.checkbox_listeners();
  $.fn.mass_edit_buttons();
});


// Change collpase icon
function changeCollapseIcon(event) {
  var source = event.currentTarget.activeElement
  if (event.type == 'shown') {
    var icon = $(source).find('.bi-plus-circle:first')
    icon.removeClass("bi-plus-circle");
    icon.addClass("bi-dash-circle");
  }
  if (event.type == 'hidden') {
    var icon = $(source).find('.bi-dash-circle:first')
    icon.removeClass("bi-dash-circle");
    icon.addClass("bi-plus-circle");
  }
}

$(document).on('shown.bs.collapse hidden.bs.collapse', function (event) {
  changeCollapseIcon(event);
})

// Flipable cards
// Use delegated event handling
$(document).on('turbolinks:load', function() {
  // Attach event handlers for flip actions
  $(document).on('click', '.flip-trigger', function() {
    $(this).closest('.card-body').find('.front').toggleClass('d-none');
    $(this).closest('.card-body').find('.back').toggleClass('d-none');
  });
});
