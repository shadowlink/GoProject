@Stones = new Meteor.Collection 'stones'

Stones.allow
    update: (userId, stone) ->
        ownsDocument userId, stone

    remove: (userId, stone) ->
        ownsDocument userId, stone

Meteor.methods
    newStone: (move, uuid) ->
        stone =
            column: move.column
            row: move.row
            stone: move.stone
            gameId: move.gameId
            chainId: uuid
            validMove: false
        Stones.insert stone

    updateStone: (move, chainId) ->
        stone =
            column: move.column
            row: move.row
            stone: move.stone
            gameId: move.gameId
            chainId: chainId
            validMove: false
        Stones.insert stone

    updateChain: (updatedChainId, chainId) ->
        Stones.update
            chainId: chainId,
            {
                $set:
                    chainId: updatedChainId
            },
            {
                multi: true
            }

    removeChain: (chainId) ->
        Stones.remove(chainId: chainId)

    removeUniqStone: (row, column) ->
        Stones.remove(row: row, column: column)

    validateStone: (row, column) ->
        Stones.update
            row: row, column: column,
            {
                $set:
                    validMove: true
            },
            {
                multi: true
            }
