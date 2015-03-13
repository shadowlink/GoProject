@MainChatLines = new Meteor.Collection 'mainChatLines'

Meteor.methods
  addMainChatLine: (text, user) ->
    line =
      text: text
      name: user
      submitted: new Date().getTime()
    MainChatLines.insert line