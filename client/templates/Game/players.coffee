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

Template.players.rendered = ->
  timerP1 = 0
  timerP2 = 0
  game = Games.find().fetch()
  Deps.autorun ->
    game = Games.find(finalized:false).fetch()
    countdown.setLabels ' milissegundo| | | hora| dia| semana| mes| año| década| século| milênio', ' milissegundos| | | horas| dias| semanas| meses| años| décadas| séculos| milênios', ' : ', ' + ', 'ahora'
    #Nos aseguramos de que estamos en la fase de juego
    #Tenemos que parar el contador del jugador que no este jugando
    window.clearInterval timerP2
    window.clearInterval timerP1

    if game[0].phase is "play"
      gameStartAt = game[0].gameStartAt
      #Tenemos que obtener la diferencia de timestamp del jugador que tenga el turno
      if game[0].player1 is game[0].turn
        playerTime = game[0].player1TimeConsumed
      else
        playerTime = game[0].player2TimeConsumed

      #Obtenemos el tiempo desde transcurrido desde que el jugador tiene el turno
      previousTimestamp = 0
      if game[0].turn is game[0].player1
        previousTimestamp = game[0].player2Timestamp
      else
        previousTimestamp = game[0].player1Timestamp

      startTime = new Date
      if previousTimestamp is 0
        startTime = new Date
      else
        startTime.setTime(previousTimestamp)

      startTime.setMilliseconds(startTime.getMilliseconds() + (game[0].time * 60 * 1000) - playerTime)

      #Activamos el contador del jugador que corresponda
      if game[0].turn is game[0].player1
        timerP1 = countdown(startTime, ((ts) ->
          if startTime < new Date
            document.getElementById('timer1').innerHTML = "00 : 00"
            Meteor.call "surrenderGame", game[0].player1, game[0].player2, game[0]
          else
            document.getElementById('timer1').innerHTML = ts.toHTML('strong')
          return
        ), countdown.MINUTES | countdown.SECONDS)
      else
        timerP2 = countdown(startTime, ((ts) ->
          if startTime < new Date
            document.getElementById('timer2').innerHTML = ts.toHTML('00 : 00')
            Meteor.call "surrenderGame", game[0].player2, game[0].player1, game[0]
          else
            document.getElementById('timer2').innerHTML = ts.toHTML('strong')
          return
        ), countdown.MINUTES | countdown.SECONDS)
