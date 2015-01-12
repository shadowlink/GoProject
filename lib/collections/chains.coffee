@Chains = new Meteor.Collection 'chains'

Meteor.methods
    newChain: (move) ->
        uuid = generateUUID()
        chain =
            column: move.column
            row: move.row
            stone: move.stone
            gameId: move.gameId
            chainId: uuid
        Chains.insert chain
        
    updateChain: (move, chainId) ->
        chain =
            column: move.column
            row: move.row
            stone: move.stone
            gameId: move.gameId
            chainId: chainId
        Chains.insert chain


#Auxiliares
generateUUID = ->
  d = new Date().getTime()
  uuid = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) ->
    r = (d + Math.random() * 16) % 16 | 0
    d = Math.floor(d / 16)
    ((if c is "x" then r else (r & 0x3 | 0x8))).toString 16
  )
  uuid