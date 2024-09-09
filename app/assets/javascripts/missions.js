$(document).on('turbolinks:load', function () {
  if ($(".missions").length !== 0 ) {
    $('#recipe').on('change', function() {
      $(this).closest('form').submit();
    });

    // Define the jQuery plugin
    $.fn.addFactorToList = function () {
        // Initialize arrays to store factors
        let plus_simple = [];
        let plus_double = [];
        let minus_simple = [];
        let minus_double = [];

        // Iterate over active toggles
        $('.factor.active, .factor-toggle.active').each(function() {
            // Get the factor-data text and clean it
            let factorData = $(this).find('.factor-data').text().trim();
            let trimmedData = factorData.replace(/[◻️◼️,]/g, '').trim();

            // Get the data-factor attribute and badge number
            let dataFactor = $(this).data('factor');
            let badgeNumber = parseInt($(this).find('.badge').text().trim(), 10);

            // Validate badgeNumber to avoid NaN, using 1 for factor-toggle
            if (isNaN(badgeNumber)) {
                badgeNumber = 1; // Default to 0 if badgeNumber is not a valid number
            }

            // Distribute trimmedData into appropriate arrays based on dataFactor
            switch (dataFactor) {
                case 1:
                    for (let i = 0; i < badgeNumber; i++) {
                        plus_simple.push(trimmedData);
                    }
                    break;
                case 3:
                    for (let i = 0; i < badgeNumber; i++) {
                        plus_double.push(trimmedData);
                    }
                    break;
                case -1:
                    for (let i = 0; i < badgeNumber; i++) {
                        minus_simple.push(trimmedData);
                    }
                    break;
                case -3:
                    for (let i = 0; i < badgeNumber; i++) {
                        minus_double.push(trimmedData);
                    }
            }
        });

      $('#factors_plus_simple').val(JSON.stringify(plus_simple));
      $('#factors_plus_double').val(JSON.stringify(plus_double));
      $('#factors_minus_simple').val(JSON.stringify(minus_simple));
      $('#factors_minus_double').val(JSON.stringify(minus_double));
    };

    // Factors value change
    $.fn.changeFactor = function($element, sign, force) {
        let dataFactor = $element.data('factor');
        let factors = parseInt($('#factors').val());
        let $badge = $element.find('.badge');
        let badgeCount = parseInt($badge.text(), 10);

        if (force || sign == 1 || badgeCount > 0) {
          $('#factors').val(factors + (dataFactor * sign))
          $badge.text(badgeCount + sign)
        }

        if (force || (badgeCount + sign) == 0) {
          $element.removeClass('active')
        } else {
          $element.addClass('active')
        }
        $.fn.addFactorToList();
    }

    $('.tokens-set').click(function () {
      var dataToken = $(this).data('token');
      $('#tokens').val(dataToken)
    });

    // Fortune button
    $('#fortune-button').click(function() {
      $('#result').addClass('d-none')
      $(this).toggleClass('active')
      $('.fortune-field').toggleClass('d-none')
      if ($(this).hasClass('active')) {
        $('#fortune').val(true);
        $('#recipe').val(0).trigger('change');
      } else {
        $('#fortune').val(false);
        $('#recipe').val($('#recipe').data('defaultRecipeId')).trigger('change');
        $('#recipe').selectpicker('refresh');
      }
    });

    // Event delegation for factors
    $('#factors-group').on('click', '.factor-toggle', function() {
      if ($(this).hasClass('active')) {
        $.fn.changeFactor($(this),-1,true);
      } else {
        $.fn.changeFactor($(this),1);
      }
    });

    $('#factors-group').on('click', '.factor', function() {
      if (event.ctrlKey) {
        $.fn.changeFactor($(this),-1);
      } else {
        $.fn.changeFactor($(this),1);
      }
    });

    // Long press event
    $('.factor').longpress(function() {
        $.fn.changeFactor($(this),-1);
    });

    // Factors value change
    $.fn.recalculateFactors = function() {
      factors = 0
      factors += (JSON.parse($('#factors_plus_simple').val()).length * 1)
      factors += (JSON.parse($('#factors_plus_double').val()).length * 3)
      factors += (JSON.parse($('#factors_minus_simple').val()).length * -1)
      factors += (JSON.parse($('#factors_minus_double').val()).length * -3)
      $('#factors').val(factors)
    }

    // Event delegation to handle dynamically added .result elements
    $(document).on('click', '.result', function() {
      $(this).toggleClass('active');
      let resultId = $(this).attr('id');
      let resultData = $(this).find('.result-data').text().trim();
      let span = '<span class="m-1 result_data result_' + resultId + '">' + resultData + '</span>';

      if ($(this).hasClass('active')) {
        $('#results_list').append(span);
        $('#results_plain').append(span);
      } else {
        $('.result_' + resultId).remove();
        $('.result_' + resultId).remove();
      }
    });
  }
});
