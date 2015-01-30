Template.gameListItem.helpers
  player1data: ->
    Users.find("_id": @player1Id).fetch()[0]

  player2data: ->
    Users.find("_id": @player2Id).fetch()[0]

  play: ->
    canPlay = false
    if @player2 is ""
      user = Meteor.user()
      game = Games.find(userId: user._id, finalized: false).count()
      if game is 0
        canPlay = true
    return canPlay

  myGame: ->
    mygame = false
    user = Meteor.user()
    if @player1 is user.profile.Usuario or @player2 is user.profile.Usuario
      mygame = true
    return mygame

  Template.gameListItem.events "click #playButton": (event) ->
    if Meteor.user()
      #Comprobamos que no este ya en otra partida
      user = Meteor.user()
      game = Games.find(userId: user._id, finalized: false).count()
      if game is 0
        Meteor.call "addUserToGame", user, this
        Router.go "game", _id: this._id
        return