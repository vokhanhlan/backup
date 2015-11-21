# ActiveAdmin Photo用 処理
$ ->
  # validate function
  validateImage = (file) ->
    # File type (jpeg/gif/png)
    unless FileValidator.filetype_validate(file.type)
      alert("画像ファイル以外のファイルが含まれています。jpeg,gif,pngを選択してください。")
      event.preventDefault()
      return false
    # File size (5MB)
    size = file.size/1024/1024
    unless FileValidator.filesize_validate(size)
      alert("画像ファイルが大きすぎます。許容量は5MBまでです。")
      event.preventDefault()
      return false
    return true


  # Preview selected image
  $('input#photo_img').on('change', (event) ->
    file = event.target.files[0]
    unless validateImage(file)
      return false
    fileReader = new FileReader()
    fileReader.onload = (event) ->
      # Remove old preview
      $(".selected-image").remove()
      # Append new preview
      loadedImageUri = event.target.result
      $("#loadedImages").append('<img class="uploaded-image selected-image" src="' + loadedImageUri + '">')
      $(".images-description").show()
      return false
    fileReader.readAsDataURL(file)
    return false
  )

  # Drag and drop
  #   This process execute only photo create page.
  droppable = $("#droppable")
  if droppable.size() > 0
    # Check File API
    unless window.FileReader
      alert("このブラウザはドラッグ&ドロップに対応していません")
      return false

    # Event cancel handler
    cancelEvent = (event) ->
      event.preventDefault()
      event.stopPropagation()
      false

    # Dropped files handler
    handleDroppedFile = (event) ->
      $.each(event.originalEvent.dataTransfer.files, (_, file) ->
        # File validation
        unless validateImage(file)
          return false

        # Create file reader
        fileReader = new FileReader()
        fileReader.onload = ((targetFile) ->
          fileName = targetFile.name
          (event) ->
            loadedImageUri = event.target.result
            # Append preview image
            $("#loadedImages").append('<img class="uploaded-image" src="' + loadedImageUri + '">')
            $(".images-description").removeClass("hide")
            # Create photo ID for post parameter's key
            hiddenInputs = $("#hiddenInputs")
            pid = hiddenInputs.find("input#imageUri").length
            # Create hidden input for image data and image file name
            hiddenInputs.append("<input id='imageUri' type='hidden' name='photo[dropped_photos][#{pid}][img]' value='#{loadedImageUri}' />")
            hiddenInputs.append("<input id='imageName' type='hidden' name='photo[dropped_photos][#{pid}][name]' value='#{fileName}' />");
            return
        )(file)

        # File read
        fileReader.readAsDataURL(file)
      )
      cancelEvent(event)
      return false

    # Binding event handler for drag and drop
    droppable.bind("dragenter", cancelEvent)
    droppable.bind("dragover",  cancelEvent)
    droppable.bind("drop", handleDroppedFile)
    return
