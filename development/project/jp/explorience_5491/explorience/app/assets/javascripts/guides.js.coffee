$ ->
  $('.guide-answer').on 'show.bs.collapse hide.bs.collapse', ()->
    $(this).prev().children('i.switch').toggleClass('eicon-open-up eicon-open-down')