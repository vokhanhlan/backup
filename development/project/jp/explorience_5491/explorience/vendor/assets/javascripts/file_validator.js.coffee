# File validation class
class FileValidator

  @filetype_validate = (arg)->
    if (!!arg) and (arg.match(/image\/jpeg|image\/gif|image\/png/))
      return true
    return false

  @filesize_validate = (arg)->
    if (!!arg) and (typeof(arg)=="number") and (arg < 5)
      return true
    return false

window.FileValidator = FileValidator
