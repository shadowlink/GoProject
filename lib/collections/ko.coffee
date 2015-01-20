@KO = new Meteor.Collection 'ko'

Meteor.methods
  newKO: (ko) ->
    KO.insert ko

  removeKO: (gameId) ->
    KO.remove(gameId: gameId)