Template.gameList.helpers games: ->
  Games.find {finalized: false},
    sort:
      submitted: -1
    limit: 6
