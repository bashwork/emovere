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
     category_images : function(category, callback) {
       $.getJSON(emovere.base + "images/category/" + category + '/2&callback=?', callback);
     },
     source_images : function(source, callback) {
       $.getJSON(emovere.base + "images/source/" + source + '/&callback=?', callback);
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
             method : $.emovere.category_images
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
             method : $.emovere.source_images
           }, Application.populate)
          .wrap('<li/>');
      });
    });
    $('body').dropdown('.dropdown-toggle');
  };

  Application.populate = function(event) {
    $('#gallery').html('');
    event.data.method(event.data.value, function(images) {
      $.each(images, function(i, image) {
        $('<img/>', {
           'class' : 'thumbnail  lightbox',
           src     : image.link,
           alt     : image.source + ":" + image.grade // TODO summary
        }).appendTo('#gallery')
          .wrap('<div class="span7 image-box" />')
      });
    });
  };
   
})(jQuery);

/**
 * start the application
 */
$(document).ready(Application.initialize);
