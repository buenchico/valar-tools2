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

$(document).on('ready', function() {
  $('.show-spinner').on('click', function() {
    $('.spinner').removeClass('d-none');
  })
});

$(document).on('shown.bs.modal', function (event) {
  $('.show-spinner').on('click', function() {
    $('.spinner').removeClass('d-none');
  })
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
  $('.toggle-visibility-button').on('click', function() {
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

// Selectpicker to act on "none" option
let suppressSelectChange = false;

$(document).on('changed.bs.select', 'select.selectpicker', function (e, clickedIndex, isSelected, previousValue) {
  if (suppressSelectChange) return;

  const $select = $(this);
  const clickedOption = $select.find('option').eq(clickedIndex);
  const clickedValue = clickedOption.val();
  const selected = $select.val() || [];

  suppressSelectChange = true;

  if (clickedValue === 'CLEAR' && isSelected) {
    // If CLEAR was selected, deselect all others
    $select.selectpicker('val', ['CLEAR']);
  } else if (selected.includes('CLEAR')) {
    // If CLEAR is already selected and user selects something else, remove CLEAR
    const newSelection = selected.filter(v => v !== 'CLEAR');
    $select.selectpicker('val', newSelection);
  }

  suppressSelectChange = false;
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

// Activating custom sorting in tables
$.fn.table_sorter =  function() {
  $("table.sortable").tablesorter({
    widgets: ['staticRow'],
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
}
$(document).on('turbolinks:load', function() {
  $.fn.table_sorter();
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

// Custom checkbox listeners

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
    $.fn.checkboxFieldUpdate(checkboxGroup);
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

$.fn.checkboxFieldUpdate = function (checkboxGroup) {
  var hiddenInput = $('#' + checkboxGroup + '_ids_field');

  var selectedIds = $(`.checkbox_selectable:visible:checked[data-checkbox='${checkboxGroup}']`)
                        .map(function () {
                          return $(this).val();
                        })
                        .get();

  // Update the hidden input field with the new list of ids, joined by commas
  hiddenInput.val(selectedIds.join(','));
}

// Select all checkboxes
$(document).on('turbolinks:load', function() {
  $.fn.checkbox_listeners();
});

// Select all checkboxes to work in modals
$(document).on('shown.bs.modal', function (event) {
  $.fn.checkbox_listeners();
});

// Filters
$.fn.tableFilters = function(filterGroup){
    var value = $(`.filterText[data-filter='${filterGroup}']`).val().toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
    var column = $(`.filterSelect[data-filter='${filterGroup}']`).children("option:selected").val();
    $("#" + filterGroup + "_list").filterTable(value, column);
}

$.fn.tableFiltersLoad =  function() {
  // Trigger filters
  $(".filterSelect").on("change", function() {
      const filterGroup = $(this).data("filter");
      $.fn.tableFilters(filterGroup); // Why I need to remove the semicolons!!!!!
  });
  $(".filterText").on("keyup", function() {
      const filterGroup = $(this).data("filter");
      $.fn.tableFilters(filterGroup); // Why I need to remove the semicolons!!!!!
  });
}

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
