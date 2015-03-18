Meteor.publish "allGames", ->
  Games.find()

Meteor.publish "moves", (gameId) ->
  check gameId, String
  Moves.find gameId: gameId

Meteor.publish "allStones", ->
  Stones.find()

Meteor.publish "stones", (gameId) ->
  check gameId, String
  Stones.find gameId: gameId

Meteor.publish "chats", (gameId) ->
  check gameId, String
  Chats.find gameId: gameId

Meteor.publish "usersGame", (gameId) ->
  Users.find gameId: gameId

Meteor.publish "users", ->
  Users.find()

Meteor.publish "mainChatLines", ->
  MainChatLines.find()

Meteor.publish "notifications", (userId) ->
  Notifications.find userIdReceiver: userId

Meteor.publish "friends", ->
  Friends.find()

Meteor.publish "userPresence", ->
  filter = {}
  Presences.find filter, fields:
    state: true
    userId: true