Template.gameList.helpers
	games: ->
		inputSearch = Session.get "inputSearch"

		if inputSearch is "" or inputSearch is undefined
			if $('#freeGames').is(':checked')
				if $('#playingGames').is(':checked')
					Games.find {finalized: false},
						sort:
							submitted: -1
				else
					Games.find {finalized: false, phase: "waiting"},
						sort:
							submitted: -1
			else
				if $('#playingGames').is(':checked')
					Games.find {finalized: false, phase: "play"},
						sort:
							submitted: -1
				else
					Games.find {finalized: false},
						sort:
							submitted: -1					
		else
			if $('#freeGames').is(':checked')
				if $('#playingGames').is(':checked')
					Games.find {finalized: false, name: {$regex : ".*"+inputSearch+".*"}},
						sort:
							submitted: -1
				else
					Games.find {finalized: false, name: {$regex : ".*"+inputSearch+".*"}, phase: "waiting"},
						sort:
							submitted: -1
			else
				if $('#playingGames').is(':checked')
					Games.find {finalized: false, name: {$regex : ".*"+inputSearch+".*"}, phase: "play"},
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
