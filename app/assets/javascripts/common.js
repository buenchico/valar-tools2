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

  // Close the dropdown if clicking outside the searchbox, button, or elements with the class 'btn-close'
  $(document).on('click', function(event) {
    // Check if the clicked element has the class 'btn-close'
    if (!$(event.target).closest('#navbarSearch, #searchbox').length && !$(event.target).closest('.modal').length) {
      $('#searchbox').dropdown('hide');
      $('#searchbox-toggle-container').removeClass('bg-dark');
      $('#searching').addClass('d-none');
    }
  });
});

// Form control clearable icon
$(document).on('ready', function () {
    $(function() {
      $('.form-control-clearable').on('click', function() {
        var $input = $(this).closest(".input-group").find(".form-control");
        $input.val("").trigger("input");
        $(this).find("i").addClass("invisible");
      });
    });

    $("input").on("input", function() {
      var clearButton = $(this).closest(".input-group").find(".form-control-clearable");
      if ($(this).val() !== "") {
        clearButton.find("i").removeClass("invisible");
      } else {
        clearButton.find("i").addClass("invisible");
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

// Selectpicker to work after cocoon nested fields
$(document).on('cocoon:after-insert', function(e, insertedItem, originalEvent) {
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

$.fn.checkbox_listeners = function() {
  $('.checkbox_selectable').change(function() {

    var checkboxGroup = $(this).data("checkbox");

    var selectAll = $(`.checkbox_select_all[data-checkbox='${checkboxGroup}']`)
    var selectItems = $(`.checkbox_selectable:visible[data-checkbox='${checkboxGroup}']`)

    if (selectItems.filter(':checked').length == selectItems.length ) {
      selectAll.prop("checked", true);
    } else {
      selectAll.prop("checked", false);
    }
    $.fn.mass_edit_buttons(checkboxGroup);
  });

  $(".checkbox_select_all").click(function () {
    var checkboxGroup = $(this).data("checkbox");

    var selectItems = $(`.checkbox_selectable:visible[data-checkbox='${checkboxGroup}']`)

    selectItems.prop('checked', $(this).prop('checked'));
    selectItems.trigger('change'); // Trigger the change event on individual checkboxes
  });
}

$.fn.mass_edit_buttons = function(checkboxGroup) {
  var countCheckedCheckboxes = $(`.checkbox_selectable[data-checkbox='${checkboxGroup}']`).filter(':checked').length;
  var massEditButtons = $(`.mass_edit_button[data-checkbox='${checkboxGroup}']`)

  if (countCheckedCheckboxes == 0 ) {
    massEditButtons.prop("disabled", true);
  }
  if (countCheckedCheckboxes != 0) {
    massEditButtons.prop("disabled", false);
  }
}

// Add hidden checkboxes for mass edit options
$.fn.checkboxSelectable = function(){
  $('.checkbox_selectable').change(function() {
    var checkboxGroup = $(this).data("checkbox");

    if (checkboxGroup !== undefined && checkboxGroup !== null && checkboxGroup !== "") {
      var form = $('#edit_multiple_' + checkboxGroup);
    } else {
      var form = $('#edit_multiple');
    }

    var objectId = $(this).val();

    var hiddenInput = $('#' + checkboxGroup + '_ids_field');
    var selectedIds = hiddenInput.val().split(',').filter(Boolean); // Splits by comma and removes empty values

    if ($(this).is(':checked')) {
      // Add armyId if it's checked and not already in the list
      if (!selectedIds.includes(objectId)) {
        selectedIds.push(objectId);
      }
    } else {
      // Remove armyId if it's unchecked
      selectedIds = selectedIds.filter(id => id !== objectId);
    }

    // Update the hidden input field with the new list of ids, joined by commas
    hiddenInput.val(selectedIds.join(','));
  });
}

// Select all checkboxes
$(document).on('turbolinks:load', function() {
  $.fn.checkbox_listeners();
  $.fn.mass_edit_buttons();
  $.fn.checkboxSelectable();
});

// Select all checkboxes to work in modals
$(document).on('shown.bs.modal', function (event) {
  $.fn.checkbox_listeners();
  $.fn.mass_edit_buttons();
  $.fn.checkboxSelectable();
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
