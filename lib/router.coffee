Router.configure
    layoutTemplate: "layout"
    loadingTemplate: "loading"
    waitOn: ->
        [
            Meteor.subscribe("games")
            Meteor.subscribe("moves")
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

Router.onBeforeAction "loading"
