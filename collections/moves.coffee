@Moves = new Meteor.Collection 'moves'

Moves.allow
    update: ownsDocument
    remove: ownsDocument


Meteor.methods
    newMove: (move) ->
        user = Meteor.user()
        Moves.insert move
        return
