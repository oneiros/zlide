(function($, deck, undefined) {
	
  var $d = $(document),

  loadSlide = function() {
    var currentSlide = $['deck']('getSlide');
    var index = currentSlide.attr('id').replace(/slide-/, '')
    $.get('/slide/' + index, function(data) {
      currentSlide.html('<textarea rows="10" cols="80">' + data + '</textarea>');
      var button = $('<button>Save</button>');
      currentSlide.append(button);
      button.click(saveSlide);
    });
  },

  saveSlide = function() {
    var currentSlide = $['deck']('getSlide');
    var index = currentSlide.attr('id').replace(/slide-/, '')
    $.post('/slide/' + index, {'slide': currentSlide.find('textarea').val()}, function() {
      window.location.reload();
    });
  };

  $d.bind('deck.init', function() {
    $d.unbind('keydown.edit').bind('keydown.edit', function(e) {
      if (e.which == 69) {
        e.preventDefault();
        loadSlide();
      }
    });
  });

})(jQuery, 'deck');
