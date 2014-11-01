Template.header.helpers({
    signInOut: function(){
        var key = Meteor.user() ? 'signOut' : 'signIn';
        return T9n.get(key);
    }
});

Template.header.events({
    'click #nav-signinout': function(event){
        if (Meteor.user())
            Meteor.logout();
        else
            Router.go('atSignIn');
    },
});