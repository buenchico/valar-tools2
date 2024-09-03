$(document).on('turbolinks:load', function () {
  if ($(".missions").length !== 0 ) {
    $('#recipe').on('change', function() {
      $(this).closest('form').submit();
    });

    // Factors value change
    $.fn.changeFactor = function($element, sign, force) {
        var dataFactor = $element.data('factor');
        var factors = parseInt($('#factors').val());
        var $badge = $element.find('.badge');
        var badgeCount = parseInt($badge.text(), 10);

        if (force || sign == 1 || badgeCount > 0) {
          $('#factors').val(factors + (dataFactor * sign))
          $badge.text(badgeCount + sign)
        }

        console.log(badgeCount)
        if ((badgeCount + sign) == 0) {
          $element.removeClass('active')
        } else {
          $element.addClass('active')
        }
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
