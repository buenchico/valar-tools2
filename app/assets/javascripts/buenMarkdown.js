(function($) {
  $.fn.buenMarkdown = function() {
    console.log($(this))
    $(this).prepend(`
      <div>
        <div class="btn btn-sm btn-light"><i class="bi bi-type-bold"></i></div>
      </div>
      `)
  };
})(jQuery);
