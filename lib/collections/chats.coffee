@Chats = new Meteor.Collection 'chats'

Meteor.methods
  addLine: (gameId, text, user) ->
    line =
      gameId: gameId
      text: text
      name: user
      submitted: new Date().getTime()
    Chats.insert line