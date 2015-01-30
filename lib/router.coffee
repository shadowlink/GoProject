Router.configure
  layoutTemplate: "layout"
  subs = new SubsManager()

Router.map ->
  @route "topList",
    path: "/"
    waitOn: ->
      subs.subscribe "allGames"
      subs.subscribe "allStones"

  @route "game",
    path: "/game/:_id"
    data: ->
      Games.findOne @params._id
    waitOn: ->
      subs.subscribe "allGames"
      subs.subscribe "usersGame"
      subs.subscribe "stones", @params._id
      subs.subscribe "chats", @params._id


  @route "login",
    path: "/login"

  @route "gameList",
    path: "/gameList"
    waitOn: ->
      subs.subscribe "allGames"
      subs.subscribe "users"

  return

