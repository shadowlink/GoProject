Meteor.publish "games", ->
    Games.find()

Meteor.publish "moves", ->
    Moves.find()

Meteor.publish "stones", ->
    Stones.find()