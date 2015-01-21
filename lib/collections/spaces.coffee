@Spaces = new Meteor.Collection 'spaces'

Meteor.methods
  updateSpaceChain: (newChainId, chainId) ->
    Spaces.update
      chainId: chainId,
      {
        $set:
          chainId: newChainId
      },
      {
        multi: true
      }

  newSpace: (column, row, chainId, gameId) ->
    space =
      column: column
      row: row
      gameId: gameId
      chainId: chainId
    Spaces.insert space