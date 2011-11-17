/**
 * Simple client for the emovere service
 */
(function($) {
 
   var emovere = {
     base : '/api/'
   };

   /**
    * public api
    */
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
     images : function(category, grade, callback) {
       $.getJSON(emovere.base + "images/" + category + '/' + grade, callback);
     },
   };

})(jQuery)

/**
 * lets build some candy
 */
$(document).ready(function() {

  // todo attach search to summary autosuggest

  $.emovere.categories(function(categories) {
    $.each(categories, function() {
      $('<a>', {
         href  : '#category-' + this,
         text  : this,
         click : function() { alert(this); }
      }).appendTo('#categories .dropdown-menu')
        .wrap('<li/>');
    });
  });

  $.emovere.sources(function(sources) {
    $.each(sources, function() {
      $('<a/>', {
         href  : '#source-' + this,
         text  : this,
         click : function() { alert(this); }
      }).appendTo('#sources .dropdown-menu')
        .wrap('<li/>');
    });
  });

  $.emovere.images('violent', 3, function(images) {
    $.each(images, function() {
      $('<img/>', {
         'class' : 'thumbnail',
         src     : image.link,
         alt     : image.source + ":" + image.grade
      }).appendTo('#gallery')
        .wrap('<div class="span7 image-box" />')
    }); // todo attach to lightbox
  });
});
