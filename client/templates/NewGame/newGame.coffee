Template.newGame.events =
  submit: (e, tmpl) ->
    e.preventDefault()
    user = Meteor.user()

    #Comprobamos que no esté en partida
    game = Games.find(userId: user._id, finalized: false).count()

    if game is 0
      komi = $("#komi").val()
      if komi is ""
        komi = 6.5
      newGame =
        name: $("#nombre").val()
        time: $("#time").val()
        boardType: $('input:radio[name=boardType]:checked').val()
        komi: komi
      Meteor.call "AddGame", newGame, (err, result) ->
        alert "No se puede crear la partida " + err.reason  if err
        return
    #Redireccionamos a la partida recién creada
    game = Games.find(userId: user._id, finalized: false).fetch()[0]
    Router.go "game", _id: game._id
    return

Template.newGame.rendered = ->
    Session.set("currentRoomId", "newGame")
