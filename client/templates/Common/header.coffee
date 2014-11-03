Template.header.helpers signInOut: ->
    key = (if Meteor.user() then "signOut" else "signIn")
    T9n.get key

Template.header.events "click #nav-signinout": (event) ->
    if Meteor.user()
        Meteor.logout()
    else
        Router.go "atSignIn"
    return
