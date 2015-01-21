Router.configure
  layoutTemplate: "layout"
  waitOn: ->
    [
      Meteor.subscribe("games")
      Meteor.subscribe("moves")
      Meteor.subscribe("stones")
      Meteor.subscribe("chats")
    ]

Router.map ->
  @route "gameList",
    path: "/"

  @route "game",
    path: "/game/:_id"
    data: ->
      Games.findOne @params._id

  @route "login",
    path: "/login"
  return

