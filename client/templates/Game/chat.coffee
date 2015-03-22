Template.chat.helpers
  lines: ->
    chat = Chats.find {gameId: this._id},
      sort:
        submitted: +1


Template.chat.events
  "click #btnChat": (event) ->
    if Meteor.user()
      user =  Meteor.user()
      text = $("#chatText").val()
      if text != ""
        Meteor.call "addLine", this._id, text, user.profile.Usuario
        $("#chatWell").scrollTop($("#chatWell")[0].scrollHeight)
        $("#chatText").val("")
      return

  "keypress input": (e) ->
    key = if e.charCode then e.charCode else if e.keyCode then e.keyCode else 0
    if key is 13
      if Meteor.user()
        user =  Meteor.user()
        text = $("#chatText").val()
        if text != ""
          Meteor.call "addLine", this._id, text, user.profile.Usuario
          $("#chatWell").scrollTop($("#chatWell")[0].scrollHeight)
          $("#chatText").val("")
        return

Template.chat.rendered = ->
  chat = Chats.find().fetch()
  window.addEventListener("resize", (e) => respondCanvas(e))
  $("#chatWell").scrollTop($("#chatWell")[0].scrollHeight)
  $("#chatWell").height( $( window ).height() - 550 )

  Deps.autorun ->
    chat = Chats.find().fetch()
    $("#chatWell").scrollTop($("#chatWell")[0].scrollHeight)

  respondCanvas = (e) ->
    $("#chatWell").height( $( window ).height() - 550 )
    return
