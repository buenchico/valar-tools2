$(document).on('turbolinks:load', function () {
  if ($(".missions").length !== 0 ) {
    $('#recipe').on('change', function() {
      $(this).closest('form').submit();
    });

    // Define the jQuery plugin
    $.fn.addFactorToList = function () {
        // Initialize arrays to store factors
        let plus = [];
        let double_plus = [];
        let minus = [];
        let double_minus = [];

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
                        plus.push(trimmedData);
                    }
                    break;
                case 3:
                    for (let i = 0; i < badgeNumber; i++) {
                        double_plus.push(trimmedData);
                    }
                    break;
                case -1:
                    for (let i = 0; i < badgeNumber; i++) {
                        minus.push(trimmedData);
                    }
                    break;
                case -3:
                    for (let i = 0; i < badgeNumber; i++) {
                        double_minus.push(trimmedData);
                    }
            }
        });

      $('#factors_plus').val(JSON.stringify(plus));
      $('#factors_double_plus').val(JSON.stringify(double_plus));
      $('#factors_minus').val(JSON.stringify(minus));
      $('#factors_double_minus').val(JSON.stringify(double_minus));
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

    // Long press event
    $('.factor').longpress(function() {
        $.fn.changeFactor($(this),-1);
    });

    // Click event
    $('.factor').click(function(event) {
      if (event.ctrlKey) {
        $.fn.changeFactor($(this),-1);
      } else {
        $.fn.changeFactor($(this),1);
      }
    });

    $('.tokens-set').click(function () {
      var dataToken = $(this).data('token');
      $('#tokens').val(dataToken)
    });
  }
});
