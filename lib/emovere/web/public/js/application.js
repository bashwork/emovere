/**
 * Simple client for the emovere service
 */
(function($) {
 
   var emovere = {
     base : '/api/'
   };

   $.emovere = {
     sources : function(callback) {
       $.getJSON(emovere.base + "source/", callback);
     },
     categories : function(callback) {
       $.getJSON(emovere.base + "category/", callback);
     },
     check : function(text, callback) {
       $.post(emovere.base + 'category/check/',
           { data : text }, callback, "json");
     },
     grade : function(text, callback) {
       $.post(emovere.base + 'category/grade/',
           { data : text }, callback, "json");
     },
     images_by_category : function(category, callback) {
       $.getJSON(emovere.base + "images/category/" + category + '/2/', callback);
     },
     images_by_source : function(source, callback) {
       $.getJSON(emovere.base + "images/source/" + source, callback);
     },
   };

})(jQuery);

/**
 * The code for managing the layout
 */
(function($) {

  Application = {};
  Application.initialize = function() {

    // todo attach search to summary autosuggest

    $.emovere.categories(function(categories) {
      $.each(categories, function(i, category) {
        $('<a>', {
           href  : '#category-' + category,
           text  : category
        }).appendTo('#categories .dropdown-menu')
          .bind('click', {
             value : category,
             method : $.emovere.images_by_category
           }, Application.populate)
          .wrap('<li/>')
      });
    });

    $.emovere.sources(function(sources) {
      $.each(sources, function(i, source) {
        $('<a>', {
           href  : '#source-' + source,
           text  : source
        }).appendTo('#sources .dropdown-menu')
          .bind('click', {
             value : source,
             method : $.emovere.images_by_source
           }, Application.populate)
          .wrap('<li/>');
      });
    });
    $('body').dropdown('.dropdown-toggle');
  };

  Application.populate = function(event) {
    $('#gallery img').fadeOut('slow', function(){
      $('#gallery').html('');
    });
    $('#titlebar a').text('Emovere|' + event.data.value);
    event.data.method(event.data.value, function(images) {
      $.each(images, function(i, image) {
        $('<img/>', {
           'class' : 'thumbnail lightbox',
           src     : image.link,
           alt     : image.summary
        }).hide().load(function() {
          $(this).appendTo('#gallery')
          .wrap('<a>').wrap('<li class="image-box" />')
          .fadeIn('slow');
        });
      });
    });
  };
   
})(jQuery);

/**
 * start the application
 */
$(document).ready(Application.initialize);
