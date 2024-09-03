$(document).on('turbolinks:load', function () {
  if ($(".missions").length !== 0 ) {
    $('#recipe').on('change', function() {
      $(this).closest('form').submit();
    });    
    $('.factor').click(function () {
      var dataFactor = $(this).data('factor');
      factors = parseInt($('#factors').val());
      $('#factors').val(factors + dataFactor)
    });
    $('.tokens-set').click(function () {
      var dataToken = $(this).data('token');
      $('#tokens').val(dataToken)
    });
  }
});
