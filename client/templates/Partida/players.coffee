Template.players.helpers
  player1: ->
    @player1

  player2: ->
    @player2

  points1: ->
    @points1

  points2: ->
    @points2

  myTurn: ->
    myTurn = false
    user = Meteor.user().profile.Usuario
    if user is @turn
      myTurn = true
    myTurn

  finalized: ->
    return @finalized

  winner1: ->
    message = ""
    if @points1 > @points2
      message = "(Vencedor)"
    return message

  winner2: ->
    message = ""
    if @points2 > @points1
      message = "(Vencedor)"
    return message

Template.players.events
  "click #surrender": (event) ->
    if Meteor.user()
      #Comprobamos que no este ya en otra partida
      user = Meteor.user()
      Meteor.call "finalizeGame", user, this
      return

  "click #pass": (event) ->
    user = Meteor.user()
    if @pass > 0
      Meteor.call "finalizeGame", user, this
    else if user.profile.Usuario is @turn
      Meteor.call "changeTurn", this, true
      return
