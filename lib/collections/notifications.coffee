@Notifications = new Meteor.Collection 'notifications'

Meteor.methods
  addNotif: (userIdSender, userIdReceiver, type, message) ->
    notif =
      userIdSender: userIdSender
      userIdReceiver: userIdReceiver
      type: type
      message: message
      submitted: new Date().getTime()
    Notifications.insert notif

   removeNotif: (id) ->
   	Notifications.remove _id:id