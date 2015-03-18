Template.header.helpers
  signInOut: ->
    key = (if Meteor.user() then "signOut" else "signIn")
    T9n.get key

Template.header.events 
  "click #nav-signinout": (event) ->
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

  myTurn: ->
    myTurn = false
    user = Meteor.user()
    game = Games.find(player1: user.profile.Usuario, finalized: false).count()
    if game is 0
      game = Games.find(player2: user.profile.Usuario, finalized: false).count()
      unless game is 0
        game = Games.find(player2: user.profile.Usuario, finalized: false).fetch()[0]
        if game.turn is user.profile.Usuario
          myTurn = true
    else
      game = Games.find(player1: user.profile.Usuario, finalized: false).fetch()[0]
      if game.turn is user.profile.Usuario
        myTurn = true
    return myTurn

Template.header.rendered = ->
  Presence.state = ->
    { currentRoomId: Session.get('currentRoomId')}
  subs = new SubsManager();
  $('.button-collapse').sideNav()
  Deps.autorun ->
    subs.subscribe "notifications", Meteor.user()._id
    notif = Notifications.find(userIdReceiver: Meteor.user()._id).fetch()
    unless notif[0] is undefined
      if notif[0].type is "friend" 
        sAlert.error(notif[0].message, {effect: 'genie', position: 'right-bottom', timeout: 6000});
      Meteor.call "removeNotif", notif[0]._id