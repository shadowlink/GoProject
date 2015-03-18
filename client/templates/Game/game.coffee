Template.game.rendered = ->
  id = this.data._id
  Session.set("currentRoomId", id)