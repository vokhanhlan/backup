# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#alert "toi la ai"
$(document).on "change", "select", ->
  locale_value = $("select").val()
  url_value = "/change_locale/"+locale_value
  $.ajax
  	type: "GET"
  	url: url_value
  	data: {locale: locale_value}
  	success: (data)->
  		alert "changed"
  	error: (data)->

	# $(document).on "click", "#btn_add_comment", -> 
 #      #check_input_comment
 #      comment_content_value = $("#comment_content").val()
 #      product_id_value      = $("#product_id").val()
 #      $.ajax
 #        type: "GET"
 #        url: "/products/comment"
 #        data: {comment_content: comment_content_value, product_id: product_id_value }
 #        success: (data)->
 #          $("#comment_content").val("")
 #          $("#comments").html data
 #          alert "Post comment success"
 #        error: (data)->
 #          alert "Loading comments error"
