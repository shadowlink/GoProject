Template.newGame.events = submit: (e, tmpl) ->
    e.preventDefault()
    newGame = name: tmpl.find("#nombre").value
    Meteor.call "AddGame", newGame, (err, result) ->
        alert "No se puede crear la partida " + err.reason  if err
        return
    return
