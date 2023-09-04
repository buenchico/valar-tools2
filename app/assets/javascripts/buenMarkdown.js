(function($) {
  $.fn.buenMarkdown = function() {
    var toolbox = $(`
      <div class="markdown-container">
        <div class="btn btn-sm btn-light ribbon">
          <i class="bi bi-type-bold"></i>
        </div><div class="btn btn-sm btn-light ribbon">
          <i class="bi bi-type-italic"></i>
        </div><div class="btn btn-sm btn-light ribbon">
          <i class="bi bi-type-italic"></i>
        </div><div class="btn btn-sm btn-light ribbon">
          <i class="bi bi-type-italic"></i>
        </div><div class="btn btn-sm btn-light ribbon">
          <i class="bi bi-type-italic"></i>
        </div><div class="btn btn-sm btn-light ribbon">
          <i class="bi bi-type-italic"></i>
        </div><div class="btn btn-sm btn-light ribbon">
          <i class="bi bi-type-italic"></i>
        </div>
      </div>
      `);
    toolbox.insertBefore($(this));
    $(this).appendTo(".markdown-container");
  };
})(jQuery);
