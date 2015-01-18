@Moves = new Meteor.Collection 'moves'

Moves.allow
    update: (userId, move) ->
        ownsDocument userId, move

    remove: (userId, move) ->
        ownsDocument userId, move


Meteor.methods
    newMove: (move) ->
        validMove = true
        remove = true

        #Comprobamos que no haya una pieza en la misma posicion
        myStone = Stones.find(gameId: move.gameId, row: move.row, column: move.column).count()
        if myStone > 0
            validMove = false
            remove = false

        if validMove
          #Comprobar si el movimiento es participe de una cadena, si lo es, se añade a esa cadena
          ## Añadir a cadena o concatenar cadenas
          stones = Stones.find(gameId: move.gameId).fetch()
          chains = []
          for stone in stones
              #Arriba
              if stone.row is move.row - 1 and stone.column is move.column
                  if stone.stone is move.stone
                      chains.push stone.chainId
                      #console.log "Derecha"
              #Abajo
              if stone.row is move.row + 1 and stone.column is move.column
                  if stone.stone is move.stone
                      chains.push stone.chainId
                      #console.log "Izquierda"
              #Derecha
              if stone.row is move.row and stone.column is move.column + 1
                  if stone.stone is move.stone
                      chains.push stone.chainId
                      #console.log "Arriba"
              #Izquierda
              if stone.row is move.row and stone.column is move.column - 1
                  if stone.stone is move.stone
                      chains.push stone.chainId
                      #console.log "Abajo"

          #Comprobamos si hay mas de una cadena adyacente y las concatenamos
          if chains.length > 1
              i=1
              while i < chains.length
                  Meteor.call "updateChain", chains[0], chains[i]
                  i++
              Meteor.call "updateStone", move, chains[0]

          if chains.length is 1
              Meteor.call "updateStone", move, chains[0]

          if chains.length is 0
              chains[0] = generateUUID()
              Meteor.call "newStone", move, chains[0]


          #Eliminar cadenas que no tengan libertades y que no sea la cadena recien creada
          #Evitar eliminar la piedra recien puesta

          distinctChains = _.uniq(stones, false, (d) ->
              d.chainId
          )
          distinctValues = _.pluck(distinctChains, "chainId")

          totalStones = Stones.find(gameId: move.gameId).fetch()
          #Crear un mapa en memoria con las posiciones de las piedras en el tablero
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

          for stone in totalStones
              board[stone.column][stone.row] = 'x'


          somethingDeleted = false
          for id in distinctValues
              if id != chains[0]
                  stones = Stones.find(chainId: id).fetch()
                  deleteChain = true
                  for stone in stones
                      freedoms = 4
                      if stone.row - 1 < 0
                          freedoms -= 1
                      else
                          if board[stone.column][stone.row - 1] is 'x'
                              freedoms -= 1
                      if stone.row + 1 > 17
                          freedoms -= 1
                      else
                          if board[stone.column][stone.row + 1] is 'x'
                              freedoms -= 1
                      if stone.column + 1 > 17
                          freedoms -= 1
                      else
                          if board[stone.column + 1][stone.row] is 'x'
                              freedoms -= 1
                      if stone.column - 1 < 0
                          freedoms -= 1
                      else
                          if board[stone.column - 1][stone.row] is 'x'
                              freedoms -= 1
                      if freedoms > 0
                          #console.log "Cadena que se salva"
                          deleteChain = false;
                          break
                  if deleteChain
                      #ELiminar cadena
                      points = Stones.find(chainId: id).count()
                      Meteor.call "updatePoints", move.gameId, points, move.player
                      Meteor.call "removeChain", id
                      somethingDeleted = true


          #Ahora comprobamos explicitamente la cadena recien insertada para comprobar si es un suicidio y no permitirlo
          #Solo lo comprobado si no ha muerto niguna cadena

          if somethingDeleted is false
              stones = Stones.find(chainId: chains[0]).fetch()
              deleteChain = true
              for stone in stones
                  freedoms = 4
                  if stone.row - 1 < 0
                      freedoms -= 1
                  else
                      if board[stone.column][stone.row - 1] is 'x'
                          freedoms -= 1
                  if stone.row + 1 > 17
                      freedoms -= 1
                  else
                      if board[stone.column][stone.row + 1] is 'x'
                          freedoms -= 1
                  if stone.column + 1 > 17
                      freedoms -= 1
                  else
                      if board[stone.column + 1][stone.row] is 'x'
                          freedoms -= 1
                  if stone.column - 1 < 0
                      freedoms -= 1
                  else
                      if board[stone.column - 1][stone.row] is 'x'
                          freedoms -= 1
                  if freedoms > 0
                      deleteChain = false;
                      break
              if deleteChain
                  #La cadena intenta suicidarse, no lo permitimos
                  #Eliminamos el ultimo movimiento
                  validMove = false


        #Insertar movimiento
        if validMove
            Moves.insert move
            Meteor.call "validateStone", move.row, move.column
        else
            if remove
              Meteor.call "removeUniqStone", move.row, move.column

        return validMove


#Auxiliares
generateUUID = ->
  d = new Date().getTime()
  uuid = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) ->
    r = (d + Math.random() * 16) % 16 | 0
    d = Math.floor(d / 16)
    ((if c is "x" then r else (r & 0x3 | 0x8))).toString 16
  )
  uuid
