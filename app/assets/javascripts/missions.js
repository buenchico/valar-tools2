$(document).on('turbolinks:load', function () {
  if ($(".missions").length !== 0 ) {
    $('.factor').click(function () {
      var dataFactor = $(this).data('factor');
      factors = parseInt($('#factors').val());
      $('#factors').val(factors + dataFactor)
    });
  }
});
