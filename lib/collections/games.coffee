# Declaración de la coleccion Partidas
@Games = new Meteor.Collection "games"
Games.allow
  update: (userId, game) ->
    ownsDocument userId, game

  remove: (userId, game) ->
    ownsDocument userId, game

Games.deny update: (userId, game, fieldNames) ->
  _.without(fieldNames, "name").length > 0

Meteor.methods
  AddGame: (newGame) ->
    user = Meteor.user()
    throw new Meteor.Error(401, "Tienes que loguearte primero")  unless user
    throw new Meteor.Error(422, "Falta el nombre!")  unless newGame.name
    game = _.extend(_.pick(newGame, "name"),
      userId: user._id
      author: user.profile.Usuario
      player1: user.profile.Usuario
      player2: ""
      player1Id: user._id
      player2Id: ""
      turn: user.profile.Usuario
      points1: 0
      points2: 0
      pass: 0
      phase: "play"
      finalized: false
      surrender: ""
      confirmPlayer1:false
      confirmPlayer2:false
      submitted: new Date().getTime()
    )
    Games.insert game

  addUserToGame: (user, game) ->
    Games.update
      _id: game._id,
      {
        $set:
          player2: user.profile.Usuario
          player2Id: user._id
      }

  changeTurn: (game, pass) ->
    newTurn = ""
    if game.turn is game.player1
      newTurn = game.player2
    else
      newTurn = game.player1

    if pass
      Games.update
        _id: game._id,
        {
          $set:
            turn: newTurn
          $inc:
            pass: 1
        }
    else
      Games.update
        _id: game._id,
        {
          $set:
            turn: newTurn
        }

  passReset: (gameId) ->
    Games.update
      _id: gameId,
      {
        $set:
          pass: 0
      }

  updatePoints: (gameId, points, player) ->
    game = Games.find(_id: gameId).fetch()[0]
    if game.player1 is player
      Games.update
        _id: gameId,
        {
          $inc:
            points1: points
        }
    else
      Games.update
        _id: gameId,
        {
          $inc:
            points2: points
        }

  surrenderGame: (looser, winner,  game) ->
    Games.update
      _id: game._id,
      {
        $set:
          surrender: looser
          winner: winner
          finalized: true
          phase: "finalized"
      }

  changeGamePhase: (game, phase) ->
    Games.update
      _id: game._id,
      {
        $set:
          phase: phase
      }    

  confirm: (game, user) ->
    game = Games.find(_id: game._id).fetch()[0]
    if user.profile.Usuario is game.player1
      Games.update
        _id: game._id,
        {
          $set:
            confirmPlayer1: true
        }  
    else
      Games.update
        _id: game._id,
        {
          $set:
            confirmPlayer2: true
        }  

 Meteor.syncMethods
  finalizeGame: (game, callback) ->
    #Recuento final de territorios
    #Primero creamos una lista de cadenas de espacios vacios
    #Para ello primero necesitamos un mapa del estado del tablero
    stones = Stones.find(gameId: game._id, marked:false).fetch()
    board = new Array(19)
    i = 0
    while i < 19
      board[i] = new Array(19)
      i++

    i = 0
    while i < 19
      j = 0
      while j < 19
        board[i][j] = 'e'
        j++
      i++
    for stone in stones
      board[stone.column][stone.row] = stone.stone

    #Ahora debemos recorrer cada espacio vacio y crear cadenas de espacios vacios
    chains = []
    spacesList = []
    i = 0
    while i < 19
      j = 0
      while j < 19
        if board[i][j] is 'e'
          #Comprobamos si hay cadenas adyacentes ya creadas
          if i - 1 >= 0
            if board[i - 1][j] is 's' #espacio conocido
              #Recuperamos la id de cadena de ese espacio
              chainId = getChainId(i-1, j, spacesList)
              chains.push(chainId)
          if i + 1 <= 18
            if board[i + 1][j] is 's' #espacio conocido
              chainId = getChainId(i+1, j, spacesList)
              chains.push(chainId)
          if j + 1 <= 18
            if board[i][j + 1] is 's' #espacio conocido
              chainId = getChainId(i, j+1, spacesList)
              chains.push(chainId)
          if j - 1 >= 0
            if board[i][j - 1] is 's' #espacio conocido
              chainId = getChainId(i, j-1, spacesList)
              chains.push(chainId)


          #Comprobamos si hay mas de una cadena y las concatenamos
          if chains.length > 1
            x = 1
            while x < chains.length
              y = 0
              while y < spacesList.length
                if spacesList[y].chainId is chains[x]
                  spacesList[y].chainId = chains[0]
                y++
              x++
            space =
              column: i
              row: j
              chainId: chains[0]
              gameId: game._id
            spacesList.push(space)
            board[i][j] = 's'

          if chains.length is 1
            space =
              column: i
              row: j
              chainId: chains[0]
              gameId: game._id
            spacesList.push(space)
            board[i][j] = 's'

          if chains.length is 0
            chains[0] = generateUUID()
            space =
              column: i
              row: j
              chainId: chains[0]
              gameId: game._id
            spacesList.push(space)
            board[i][j] = 's'

          chains = []
        j++
      i++

    #Segundo, comprobamos que rodea a las cadenas vacias, negras, blancas o mixtas

    distinctSpaceChains = _.uniq(spacesList, false, (d) ->
      d.chainId
    )
    distinctValues = _.pluck(distinctSpaceChains, "chainId")

    blackPoints = 0
    whitePoints = 0
    for id in distinctValues
      white = false
      black = false
      for space in spacesList
        if space.chainId is id
          if space.column - 1 >= 0
            if board[space.column - 1][space.row] is 'w'
              white = true
            else if board[space.column - 1][space.row] is 'b'
              black = true
          if space.column + 1 <= 18
            if board[space.column + 1][space.row] is 'w'
              white = true
            else if board[space.column + 1][space.row] is 'b'
              black = true
          if space.row - 1 >= 0
            if board[space.column][space.row - 1] is 'w'
              white = true
            else if board[space.column][space.row - 1] is 'b'
              black = true
          if space.row + 1 <= 18
            if board[space.column][space.row + 1] is 'w'
              white = true
            else if board[space.column][space.row + 1] is 'b'
              black = true
      if white is true and black is false
        for space in spacesList
          if space.chainId is id
            Meteor.call "addSpaceStone", space, 'w'
            whitePoints += 1
      if white is false and black is true
        for space in spacesList
          if space.chainId is id
            Meteor.call "addSpaceStone", space, 'b'
            blackPoints += 1



    #Actualizacion del estado del juego
    Games.update
      _id: game._id,
      {
        $set:
          finalized: true
          phase: "finalized"
        $inc:
          points1: blackPoints
          points2: whitePoints + 6.5
      }

    #Comprobamos quien ha ganado y actualizamos el ganador 
    winner = ""
    if game.points1 > game.points2
      winner = game.player1
    else
      winner = game.player2

    Games.update
      _id: game._id,
      {
        $set:
          winner: winner
      }   
    callback(err, result)

#Auxiliares
generateUUID = ->
  d = new Date().getTime()
  uuid = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) ->
    r = (d + Math.random() * 16) % 16 | 0
    d = Math.floor(d / 16)
    ((if c is "x" then r else (r & 0x3 | 0x8))).toString 16
  )
  uuid

getChainId = (column, row, list) ->
  i = 0
  chainId = ""
  while i < list.length
    if list[i].column is column and list[i].row is row
      chainId = list[i].chainId
    i++
  chainId
