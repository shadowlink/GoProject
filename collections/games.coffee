# Declaración de la coleccion Partidas
@Games = new Meteor.Collection "games"
Games.allow
    update: ownsDocument
    remove: ownsDocument

Games.deny update: (userId, game, fieldNames) ->
    _.without(fieldNames, "name").length > 0

Meteor.methods AddGame: (newGame) ->
    user = Meteor.user()
    throw new Meteor.Error(401, "Tienes que loguearte primero")  unless user
    throw new Meteor.Error(422, "Falta el nombre!")  unless newGame.name
    game = _.extend(_.pick(newGame, "name"),
        userId: user._id
        author: user.username
        submitted: new Date().getTime()
    )
    Games.insert game
