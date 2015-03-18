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

  player1User: ->
    user1 = Users.find("_id": @player1Id).fetch()[0]
    return user1


  player2User: ->
    user2
    if @player2
      user2  = Users.find("_id": @player2Id).fetch()[0]
    return user2

  myGame: ->
    user = Meteor.user()
    myGame = false
    if user.profile.Usuario is @player1 or user.profile.Usuario is @player2
      myGame = true
    myGame

  recount: ->
    count = false
    if this.phase is "count"
      count = true
    count

  canConfirm: ->
    canConfirm = false
    user = Meteor.user()
    if user.profile.Usuario is @player1
      if @confirmPlayer1 is false
        canConfirm = true
    else
      if @confirmPlayer2 is false
        canConfirm = true
    console.log canConfirm
    canConfirm

  infoBoard: ->
    message = ""
    if this.phase is "finalized"
          message = "La victoria es para " + this.winner
    else if this.phase is "count"
          message = "Marcad las piezas que creais muertas. Confirmad para proceder al recuento de territorios."
    else if this.phase is "processing"
      message = "Procesando territorios..."
    else if this.phase is "play"
      message = "Turno de " + this.turn
    message

  buttonSurrender: ->
    html = ""
    if this.phase is "play"
      html = "<a id='surrender' class='waves-effect waves-light btn'><i class='mdi-av-new-releases left'></i>Rendir</a>"
    else
      html = "<a class='waves-effect waves-light btn disabled'><i class='mdi-av-new-releases left'></i>Rendir</a>"
    html

  buttonPass: ->
    html = ""
    if this.turn is Meteor.user().profile.Usuario and this.phase is "play"
      html = "<a id='pass' class='waves-effect waves-light btn'><i class='mdi-av-repeat left'></i>Pasar</a>"
    else
      html = "<a class='waves-effect waves-light btn disabled'><i class='mdi-av-repeat left'></i>Pasar</a>"
    html

  buttonConfirm: ->
    html = ""
    user = Meteor.user()
    if user.profile.Usuario is @player1
      if @confirmPlayer1 is false
        canConfirm = true
    else
      if @confirmPlayer2 is false
        canConfirm = true

    if this.phase is "count" and canConfirm
      html = "<a id='confirm' class='waves-effect waves-light btn'><i class='mdi-action-done left'></i>Confirmar</a>"
    else
      html = "<a class='waves-effect waves-light btn disabled'><i class='mdi-action-done left'></i>Confirmar</a>"
    html

  viewers: ->
    viewers = Presences.find state: currentRoomId: Session.get('currentRoomId')
    v = viewers.fetch()
    count = viewers.count()
    i=0
    while i<viewers.count()
      if v[i].userId
        if v[i].userId is @player1Id or v[i].userId is @player2Id
          count--
      i++
    count

Template.players.events
  "click #surrender": (event) ->
    user = Meteor.user()
    winner = ""
    looser = user.profile.Usuario
    if looser is @player1
      winner = @player2
    else
      winner = @player1

    if user
      Meteor.call "surrenderGame", looser, winner, this
      return

  "click #pass": (event) ->
    user = Meteor.user()
    if @pass > 0
      Meteor.call "changeGamePhase", this, "count"
    else if user.profile.Usuario is @turn
      Meteor.call "changeTurn", this, true
      return

  "click #confirm": (event) ->
    user = Meteor.user()

    if @confirmPlayer1 or @confirmPlayer2
      Meteor.call "confirm", this, user
      Meteor.call "changeGamePhase", this, "processing"
      Meteor.call "finalizeGame", this
    else
      Meteor.call "confirm", this, user
      return