Template.mainChat.helpers
  lines: ->
    chat = MainChatLines.find()

  usersOnline: ->
    Meteor.users.find 'status.online': true

Template.mainChat.events
  "click #btnChat": (e) ->
    if Meteor.user()
      user =  Meteor.user()
      text = $("#chatText").val()
      if text != ""
        Meteor.call "addMainChatLine", text, user.profile.Usuario
        $(".mainChatWell").scrollTop($(".mainChatWell")[0].scrollHeight)
        $("#chatText").val("")
      return

  "keypress input": (e) ->
    key = if e.charCode then e.charCode else if e.keyCode then e.keyCode else 0
    if key is 13
      if Meteor.user()
        user =  Meteor.user()
        text = $("#chatText").val()
        if text != ""
          Meteor.call "addMainChatLine", text, user.profile.Usuario
          $(".mainChatWell").scrollTop($(".mainChatWell")[0].scrollHeight)
          $("#chatText").val("")
        return

  "click .friend-invite": (e) ->
    numInvites = Friends.find("sender._id":Meteor.user()._id, "receiver._id": this._id).count()
    if numInvites is 0
      Meteor.call "addNotif", Meteor.user()._id, this._id, "friend", Meteor.user().profile.Usuario + " te ha enviado una solicitud de amistad."
      Meteor.call "inviteFriend", Meteor.user(), this


Template.mainChat.rendered = ->
  Session.set("currentRoomId", "chat")
  chat = MainChatLines.find().fetch()
  window.addEventListener("resize", (e) => respondCanvas(e))
  $(".mainChatWell").height( $( window ).height() - 310 )
  $(".mainChatWell").scrollTop($(".mainChatWell")[0].scrollHeight)
  #sAlert.info('Boom! Something went wrong!', {effect: 'bouncyflip', position: 'right-bottom', timeout: '5000'})

  Deps.autorun ->
    chat = MainChatLines.find().fetch()
    $(".mainChatWell").scrollTop($(".mainChatWell")[0].scrollHeight)
    $('.tooltipped').tooltip({delay: 50});

  respondCanvas = (e) ->
    $(".mainChatWell").height( $( window ).height() - 310 )
    return

return