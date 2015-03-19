Router.configure
  layoutTemplate: "layout"
  loadingTemplate: 'loading'
  subs = new SubsManager()

Router.map ->
  @route "main",
    path: "/"
    onBeforeAction: (pause) ->
      if Meteor.user()
        if !Meteor.user().profile.Usuario
          Router.go "asigName"
        else
          this.next()
      else
        this.next()
        
  @route "topList",
    path: "/topList"
    waitOn: ->
      subs.subscribe "allGames"
      subs.subscribe "allStones"
    fastRender: true
    onBeforeAction: (pause) ->
      if Meteor.user()
        if !Meteor.user().profile.Usuario
          Router.go "asigName"
        else
          this.next()
      else
        this.next()

  @route "newGame",
    path: "/newGame"
    fastRender: true
    onBeforeAction: (pause) ->
      if Meteor.user()
        if !Meteor.user().profile.Usuario
          Router.go "asigName"
        else
          this.next()
      else
        this.next()

  @route "asigName",
      path: "/asigName"
      fastRender: true

  @route "game",
    path: "/game/:_id"
    data: ->
      Games.findOne @params._id
    waitOn: ->
      subs.subscribe "allGames"
      subs.subscribe "usersGame"
      subs.subscribe "stones", @params._id
      subs.subscribe "chats", @params._id
      subs.subscribe "userPresence"
    fastRender: true
    onBeforeAction: (pause) ->
      if Meteor.user()
        if !Meteor.user().profile.Usuario
          Router.go "asigName"
        else
          this.next()
      else
        this.next()

  @route "login",
    path: "/login"
    fastRender: true

  @route "friendlist",
    path: "/friendlist"
    waitOn: ->
      subs.subscribe "friends"
    fastRender: true

  @route "profile",
    path: "/profile/:_id"
    data: ->
      Users.findOne @params._id
    waitOn: ->
      subs.subscribe "allGames"
      subs.subscribe "users"
    fastRender: true

  @route "gameList",
    path: "/gameList"
    waitOn: ->
      subs.subscribe "allGames"
      subs.subscribe "users"
    fastRender: true
    onBeforeAction: (pause) ->
      if Meteor.user()
        if !Meteor.user().profile.Usuario
          Router.go "asigName"
        else
          this.next()
      else
        this.next()

  @route "mainChat",
    path: "/mainChat"
    waitOn: ->
      subs.subscribe "users"
      subs.subscribe "mainChatLines"
      subs.subscribe "friends"
    fastRender: true
    onBeforeAction: (pause) ->
      if Meteor.user()
        if !Meteor.user().profile.Usuario
          Router.go "asigName"
        else
          this.next()
      else
        this.next()

  return
