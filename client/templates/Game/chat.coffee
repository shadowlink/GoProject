Template.chat.helpers
  lines: ->
    chat = Chats.find {gameId: this._id},
      sort:
        submitted: +1


Template.chat.events
  "click #btnChat": (event) ->
    if e.charCode is 13 or e.charCode is 0
      if Meteor.user()
        user =  Meteor.user()
        text = $("#chatText").val()
        Meteor.call "addLine", this._id, text, user.profile.Usuario
        $("#chatWell").scrollTop($("#chatWell")[0].scrollHeight)
        $("#chatText").val("")
        return

  "keypress input": (e) ->
    if e.charCode is 13 or e.charCode is 0
      if Meteor.user()
        user =  Meteor.user()
        text = $("#chatText").val()
        Meteor.call "addLine", this._id, text, user.profile.Usuario
        $("#chatWell").scrollTop($("#chatWell")[0].scrollHeight)
        $("#chatText").val("")
        event.stopPropagation()
        return

Template.chat.rendered = ->
  chat = Chats.find().fetch()
  window.addEventListener("resize", (e) => respondCanvas(e))
  $("#chatWell").scrollTop($("#chatWell")[0].scrollHeight)
  $("#chatWell").height( $( window ).height() - 520 )

  Deps.autorun ->
    chat = Chats.find().fetch()
    $("#chatWell").scrollTop($("#chatWell")[0].scrollHeight)

  respondCanvas = (e) ->
    $("#chatWell").height( $( window ).height() - 520 )
    return