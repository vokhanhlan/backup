$ ->
  @form = $('#new_user')
  $validator = @form.validate(
    rules:
      "user[email]":
        required: true
        email: true
      "user[password]":
        required: true
        minlength: 8
      "user[password_confirmation]":
        required: true
        equalTo: "#user_password"
      "user[name]":
        required: true

    errorClass: "help-block"
    errorElement: "span"
    errorPlacement: (error, element) ->
      if element.hasClass("password")
        $(element).parent().after(error)
      else
        error.insertAfter(element)
  )
