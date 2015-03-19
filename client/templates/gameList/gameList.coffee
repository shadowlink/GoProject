Template.gameList.helpers
	games: ->
		inputSearch = Session.get "inputSearch"

		if inputSearch is "" or inputSearch is undefined
			Games.find {finalized: false},
				sort:
					submitted: -1
		else
			Games.find {finalized: false, name: {$regex : ".*"+inputSearch+".*"}},
				sort:
					submitted: -1

	myUser: ->
		Meteor.user()


Template.gameList.events
	"keyup input": (e) ->
		Session.set("inputSearch", $("#gameName").val())

Template.gameList.rendered = ->
 	Session.set("currentRoomId", "gameList")