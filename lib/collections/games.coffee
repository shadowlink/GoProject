# Declaración de la coleccion Partidas
@Games = new Meteor.Collection "games"
Games.allow
    update: (userId, game) ->
        ownsDocument userId, game

    remove: (userId, game) ->
        ownsDocument userId, game

Games.deny update: (userId, game, fieldNames) ->
    _.without(fieldNames, "name").length > 0

Meteor.methods AddGame: (newGame) ->
    user = Meteor.user()
    throw new Meteor.Error(401, "Tienes que loguearte primero")  unless user
    throw new Meteor.Error(422, "Falta el nombre!")  unless newGame.name
    game = _.extend(_.pick(newGame, "name"),
        userId: user._id
        author: user.profile.Usuario
        player1: user.profile.Usuario
        player2: ""
        turn: user.profile.Usuario
        points1: 0
        points2: 0
        submitted: new Date().getTime()
    )
    Games.insert game

Meteor.methods addUserToGame: (user, game) ->
    Games.update
        _id: game._id,
        {
            $set:
                player2: user.profile.Usuario
        }

Meteor.methods changeTurn: (game) ->
    newTurn = ""
    if game.turn is game.player1
        newTurn = game.player2
    else
        newTurn = game.player1
    Games.update
        _id: game._id,
        {
            $set:
                turn: newTurn
        }

Meteor.methods updatePoints: (gameId, points, player) ->
    game = Games.find(_id: gameId).fetch()[0]
    if game.player1 is player
      Games.update
          _id: gameId,
          {
              $inc:
                  points1: points
          }
    else
      Games.update
          _id: gameId,
          {
              $inc:
                  points2: points
          }