Template.friendlist.helpers
  friends: ->
    Friends.find "sender._id":Meteor.user()._id, accepted: true

  invitations: ->
  	Friends.find accepted: false, "receiver._id": Meteor.user()._id

  playing: ->
    playing = Games.find(player1Id:this.receiver._id, finalized:false).count() + Games.find(player2Id:this.receiver._id, finalized:false).count()
    if playing > 0
      return true
    else
      return false

  gameUrl: ->
    gameid = ""
    user = this.receiver
    game = Games.find(player1: user.profile.Usuario, finalized: false).count()
    if game is 0
      game = Games.find(player2: user.profile.Usuario, finalized: false).count()
      if game is 0
        gameid = ""
      else
        gameid = Games.find(player2: user.profile.Usuario, finalized: false).fetch()[0]._id
    else
      gameid = Games.find(player1: user.profile.Usuario, finalized: false).fetch()[0]._id
    return gameid

  isOnline: ->
    user = Users.find(_id:this.receiver._id).fetch()[0]
    return user.status.online

Template.friendlist.events
	"click .acceptInvite": (e) ->
		Meteor.call "addNotif", Meteor.user()._id, this.sender._id, "friend", Meteor.user().profile.Usuario + " ha aceptado tu solicitud de amistad."
		Meteor.call "acceptFriend", this._id

	"click .cancelInvite": (e) ->
		Meteor.call "addNotif", Meteor.user()._id, this.sender._id, "friend", Meteor.user().profile.Usuario + " ha cancelado tu solicitud de amistad."
		Meteor.call "cancelFriend", this._id

Template.friendlist.rendered = ->
	Session.set("currentRoomId", "friendList")
	Deps.autorun ->
		$('.tooltipped').tooltip({delay: 50});
