Template.gameList.helpers games: ->
  Games.find {},
    sort:
      submitted: -1
    limit: 6
