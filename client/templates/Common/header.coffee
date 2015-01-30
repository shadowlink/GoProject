Template.header.helpers
  signInOut: ->
    key = (if Meteor.user() then "signOut" else "signIn")
    T9n.get key

Template.header.events "click #nav-signinout": (event) ->
  if Meteor.user()
    Meteor.logout()
  else
    Router.go "atSignIn"
  return

Template.header.helpers
  inGame: ->
    if Meteor.user()
      ingame = true;
      user = Meteor.user()
      game = Games.find(player1: user.profile.Usuario, finalized: false).count() + Games.find(player2: user.profile.Usuario, finalized: false).count()
      ingame = false if game is 0
      return ingame

  gameUrl: ->
    if Meteor.user()
      gameid = ""
      user = Meteor.user()
      game = Games.find(player1: user.profile.Usuario, finalized: false).count()
      if game is 0
        game = Games.find(player2: user.profile.Usuario, finalized: false).count()
        if game is 0
          gameid = ""
        else
          gameid = Games.find(player2: user.profile.Usuario, finalized: false).fetch()[0]._id
      else
        gameid = Games.find(player1: user.profile.Usuario, finalized: false).fetch()[0]._id
    return gameid

  perfil: ->
    Meteor.user().profile.Usuario

  myUser: ->
    Meteor.user()
