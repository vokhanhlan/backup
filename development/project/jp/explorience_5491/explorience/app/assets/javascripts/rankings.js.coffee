class Ranking
  @init: () ->
    this.bindingAjaxHandler()
    this.sortableSetup()

  @bindingAjaxHandler: () ->
    $(document).on 'click', '[data-rank]', (event) ->
      url  = event.currentTarget.dataset['url']
      rank = event.currentTarget.dataset['rank']
      unless rank == ""
        ajax_post(url, {rank: rank})
      return false

  @sortableSetup: () ->
    $ ->
      # Initial setting
      $('.sortable-contents').sortable
        items:       '> .experience--mini-panel'
        axis:        'y'
        cancel:      '.undraggable'
        containment: 'parent'
        cursor:      'row-resize'
        handle:      '.experience--mini-panel__handle'
        opacity:     0.7
        placeholder: 'experience--placeholder'
        revert:      50
        tolerance:   'pointer'

        update: (event, movedItem) ->
          target = $(movedItem.item)
          url          = target.parent().data().url
          originalRank = target.find('[data-rank]').data().rank
          nextElement  = target.next().find('[data-rank]')
          expCount     = $('.infinite-content').length
          $('.page.current').text(Math.ceil(expCount/10))
          $('#experienceContents').infinitescroll('pause')
          if nextElement.length > 0
            insertRank = nextElement.data().rank
          else
            insertRank = ""
          if insertRank == ""
            lowest = true
          ajax_post(
            url,
            {
              src_rank:  originalRank,
              dest_rank: insertRank,
              lowest:    lowest,
              exp_count: expCount
            }
          )

        stop: (event, movedItem) ->
          movedItem.item.effect('highlight', {color: '#fc7faa', 500})

  ajax_post = (destUrl, postData) ->
    $.ajax({
      type: 'POST'
      url:  destUrl
      data: postData
      success: ()->
        console.log('Ajax POST was completed.')
        return false
      error: ()->
        console.log('Failed to Ajax POST.')
        return false
    })

Ranking.init()
