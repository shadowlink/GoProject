Template.profile.helpers
  games: ->
    user = Users.find(_id:this._id).fetch()[0]
    Games.find
      '$or': [
        { 'player1': user.profile.Usuario }
        { 'player2': user.profile.Usuario }
      ]
      '$and': [ { 'finalized': true } ]

  iamWinner: ->
    user = Users.find(_id:Template.parentData(1)._id).fetch()[0]
    winner = false
    if @winner is user.profile.Usuario
      winner = true
    winner

  wins: ->
    user = Users.find(_id:this._id).fetch()[0]
    Games.find(finalized:true, winner: user.profile.Usuario).count()

  looses: ->
    user = Users.find(_id:this._id).fetch()[0]
    games = Games.find
      '$or': [
        { 'player1': user.profile.Usuario }
        { 'player2': user.profile.Usuario }
      ]
      '$and': [ { 'finalized': true } ]

    played = games.count()
    winn = Games.find(finalized:true, winner: user.profile.Usuario).count()
    looses = played - winn
    looses

  percent: -> 
    user = Users.find(_id:this._id).fetch()[0]
    games = Games.find
      '$or': [
        { 'player1': user.profile.Usuario }
        { 'player2': user.profile.Usuario }
      ]
      '$and': [ { 'finalized': true } ]

    played = games.count()
    winn = Games.find(finalized:true, winner: user.profile.Usuario).count()
    looses = played - winn
    percent = Math.round (winn * 100)/played


Template.profile.rendered = ->
  window.addEventListener("resize", (e) => respondCanvas(e))
  $("#profile_list").height( $( window ).height() - 260 )

  respondCanvas = (e) ->
    $("#profile_list").height( $( window ).height() - 260 )
    return