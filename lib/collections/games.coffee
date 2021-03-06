# Declaración de la coleccion Partidas
@Games = new Meteor.Collection "games"

Games.initEasySearch "name"

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
    throw new Meteor.Error(422, "Falta el tipo de tablero!")  unless newGame.boardType
    throw new Meteor.Error(422, "Falta el tiempo!")  unless newGame.time
    throw new Meteor.Error(422, "Falta el komi!")  unless newGame.komi
    game = _.extend(_.pick(newGame, "name", "boardType", "komi", "time"),
      userId: user._id
      author: user.profile.Usuario
      player1: user.profile.Usuario
      player2: ""
      player1Id: user._id
      player2Id: ""
      player1Timestamp: 0
      player2Timestamp: 0
      player1TimeConsumed: 0
      player2TimeConsumed: 0
      turn: user.profile.Usuario
      points1: 0
      points2: 0
      pass: 0
      phase: "waiting"
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
          phase: "play"
          gameStartAt: new Date().getTime()
      }

  changeTurn: (game, pass) ->
    newTurn = ""
    if game.turn is game.player1
      newTurn = game.player2
    else
      newTurn = game.player1

    nowTime = new Date().getTime()

    if pass
      if newTurn is game.player2
        offset = game.player2Timestamp.valueOf()
        if offset is 0
          offset = game.gameStartAt.valueOf()
        incTime = nowTime.valueOf() - offset
        Games.update
          _id: game._id,
          {
            $set:
              turn: newTurn
              player1Timestamp: nowTime
            $inc:
              player1TimeConsumed: incTime
              pass: 1
          }
      else if newTurn is game.player1
        offset = game.player1Timestamp.valueOf()
        if offset is 0
          offset = game.gameStartAt.valueOf()
        incTime = nowTime.valueOf() - offset
        Games.update
          _id: game._id,
          {
            $set:
              turn: newTurn
              player2Timestamp: nowTime
            $inc:
              player2TimeConsumed: incTime
              pass: 1
          }
    else
      if newTurn is game.player2
        offset = game.player2Timestamp.valueOf()
        if offset is 0
          offset = game.gameStartAt.valueOf()
        incTime = nowTime.valueOf() - offset
        Games.update
          _id: game._id,
          {
            $set:
              turn: newTurn
              player1Timestamp: nowTime
            $inc:
              player1TimeConsumed: incTime
          }
      else if newTurn is game.player1
        offset = game.player1Timestamp.valueOf()
        if offset is 0
          offset = game.gameStartAt.valueOf()
        incTime = nowTime.valueOf() - offset
        Games.update
          _id: game._id,
          {
            $set:
              turn: newTurn
              player2Timestamp: nowTime
            $inc:
              player2TimeConsumed: incTime
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
    #Obtenemos el GOR previo de cada jugador
    p1 = Users.find(_id:game.player1Id).fetch()[0]
    p2 = Users.find(_id:game.player2Id).fetch()[0]

    GOR1 = p1.profile.GOR
    GOR2 = p2.profile.GOR

    if GOR1 is undefined
      GOR1 = 100
    if GOR2 is undefined
      GOR2 = 100

    newP1 = 0
    newP1 = 0

    if winner is game.player1
      newP1 = newRatingIfWon(GOR1, GOR2)
      newP2 = newRatingIfLost(GOR2, GOR1)
    else if winner is game.player2
      newP1 = newRatingIfLost(GOR1, GOR2)
      newP2 = newRatingIfWon(GOR2, GOR1)

    Users.update
      _id: p1._id,
      {
        $set:
          "profile.GOR": newP1
      }

    Users.update
      _id: p2._id,
      {
        $set:
          "profile.GOR": newP2
      }

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

  finalizeGame: (game) ->
    #Recuento final de territorios
    #Primero creamos una lista de cadenas de espacios vacios
    #Para ello primero necesitamos un mapa del estado del tablero
    if game.boardType is "19x19"
      NUMBER_OF_COLS = 19
      NUMBER_OF_ROWS = 19
    else if game.boardType is "13x13"
      NUMBER_OF_COLS = 13
      NUMBER_OF_ROWS = 13
    else if game.boardType is "9x9"
      NUMBER_OF_COLS = 9
      NUMBER_OF_ROWS = 9
    stones = Stones.find(gameId: game._id, marked:false).fetch()
    board = new Array(NUMBER_OF_COLS)
    i = 0
    while i < NUMBER_OF_COLS
      board[i] = new Array(NUMBER_OF_ROWS)
      i++

    i = 0
    while i < NUMBER_OF_COLS
      j = 0
      while j < NUMBER_OF_ROWS
        board[i][j] = 'e'
        j++
      i++
    for stone in stones
      board[stone.column][stone.row] = stone.stone

    #Ahora debemos recorrer cada espacio vacio y crear cadenas de espacios vacios
    chains = []
    spacesList = []
    i = 0
    while i < NUMBER_OF_COLS
      j = 0
      while j < NUMBER_OF_ROWS
        if board[i][j] is 'e'
          #Comprobamos si hay cadenas adyacentes ya creadas
          if i - 1 >= 0
            if board[i - 1][j] is 's' #espacio conocido
              #Recuperamos la id de cadena de ese espacio
              chainId = getChainId(i-1, j, spacesList)
              chains.push(chainId)
          if i + 1 <= NUMBER_OF_COLS-1
            if board[i + 1][j] is 's' #espacio conocido
              chainId = getChainId(i+1, j, spacesList)
              chains.push(chainId)
          if j + 1 <= NUMBER_OF_COLS-1
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
          if space.column + 1 <= NUMBER_OF_COLS-1
            if board[space.column + 1][space.row] is 'w'
              white = true
            else if board[space.column + 1][space.row] is 'b'
              black = true
          if space.row - 1 >= 0
            if board[space.column][space.row - 1] is 'w'
              white = true
            else if board[space.column][space.row - 1] is 'b'
              black = true
          if space.row + 1 <= NUMBER_OF_COLS-1
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
          points2: whitePoints + parseFloat(game.komi)
      }

    #Comprobamos quien ha ganado y realizamos los cálculos de GOR
    game = Games.find(_id:game._id).fetch()[0]
    updateELORatings(game)


#Auxiliares
updateELORatings = (game) ->
    #Comprobamos quien ha ganado
    winner = ""
    if game.points1 > game.points2
      winner = game.player1
    else
      winner = game.player2

    #Obtenemos el GOR previo de cada jugador
    p1 = Users.find(_id:game.player1Id).fetch()[0]
    p2 = Users.find(_id:game.player2Id).fetch()[0]

    GOR1 = p1.profile.GOR
    GOR2 = p2.profile.GOR

    if GOR1 is undefined
      GOR1 = 100
    if GOR2 is undefined
      GOR2 = 100

    newP1 = 0
    newP1 = 0
    if game.points1>game.points2
      newP1 = newRatingIfWon(GOR1, GOR2)
      newP2 = newRatingIfLost(GOR2, GOR1)
    else if game.points1<game.points2
      newP1 = newRatingIfLost(GOR1, GOR2)
      newP2 = newRatingIfWon(GOR2, GOR1)
    else if game.points1 is game.points2
      newP1 = newRatingIfTied(GOR1, GOR2)
      newP2 = newRatingIfTied(GOR2, GOR1)

    Users.update
      _id: p1._id,
      {
        $set:
          "profile.GOR": newP1
      }

    Users.update
      _id: p2._id,
      {
        $set:
          "profile.GOR": newP2
      }

    Games.update
      _id: game._id,
      {
        $set:
          winner: winner
      }

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

#ELO

newRatingIfWon = (rating, opponent_rating) ->
  odds = expectedScore(rating, opponent_rating)
  newRating odds, 1, rating

newRatingIfLost = (rating, opponent_rating) ->
  odds = expectedScore(rating, opponent_rating)
  newRating odds, 0, rating

newRatingIfTied = (rating, opponent_rating) ->
  odds = expectedScore(rating, opponent_rating)
  newRating odds, 0.5, rating

newRating = (expected_score, actual_score, previous_rating) ->
  difference = actual_score - expected_score
  rating = Math.round(previous_rating + getKFactor(previous_rating) * difference)
  if rating < -Infinity
    rating = -Infinity
  else if rating > Infinity
    rating = Infinity
  rating

getKFactor = (rating) ->
  k_factor = 32
  k_factor

expectedScore = (rating, opponent_rating) ->
  difference = opponent_rating - rating
  1 / (1 + 10 ** (difference / 400))
