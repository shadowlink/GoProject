user = Meteor.user()

Template.asigName.events =
  submit: (e, tmpl) ->
    e.preventDefault()
    user = Meteor.user()
    newName = $("#nombre").val()
    Users.update
      _id: user._id,
      {
        $set:
          "profile.Usuario": newName
      }
    Router.go "/"
    return

Template.asigName.rendered = ->
    Session.set("currentRoomId", "asigName")
    user = Meteor.user()
    unless Meteor.user().profile.Usuario is ""
        Router.go "/"
    