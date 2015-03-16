Template.friendlist.helpers
  friends: ->
    Friends.find "sender._id":Meteor.user()._id, accepted: true

  invitations: ->
  	Friends.find accepted: false, "receiver._id": Meteor.user()._id


Template.friendlist.events
	"click .acceptInvite": (e) ->
		Meteor.call "addNotif", Meteor.user()._id, this.sender._id, "friend", Meteor.user().profile.Usuario + " ha aceptado tu solicitud de amistad."
		Meteor.call "acceptFriend", this._id

	"click .cancelInvite": (e) ->
		Meteor.call "addNotif", Meteor.user()._id, this.sender._id, "friend", Meteor.user().profile.Usuario + " ha cancelado tu solicitud de amistad."
		Meteor.call "cancelFriend", this._id

Template.friendlist.rendered = ->
  Deps.autorun ->
    $('.tooltipped').tooltip({delay: 50});