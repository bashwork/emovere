/**
 * Simple client for the emovere service
 */
(function($) {
 
   var emovere = {
     base : 'http://localhost:4567/api/'
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
     images : function(category, callback) {
       $.getJSON(emovere.base + "images/" + category, callback);
     },
   };

})(jQuery)

