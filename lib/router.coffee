Router.configure
    layoutTemplate: "layout"
    waitOn: ->
        [
            Meteor.subscribe("games")
            Meteor.subscribe("moves")
        ]

Router.map ->
    @route "gameList",
        path: "/"
        fastRender : true

    @route "game",
        path: "/game/:_id"
        data: ->
            Games.findOne @params._id
        fastRender : true
        
    @route "login",
        path: "/login"
    return

