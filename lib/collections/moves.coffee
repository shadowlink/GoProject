@Moves = new Meteor.Collection 'moves'

Moves.allow
    update: (userId, move) ->
        ownsDocument userId, move

    remove: (userId, move) ->
        ownsDocument userId, move


Meteor.methods
    newMove: (move) ->
        #Comprobar si el movimiento es participe de una cadena, si lo es, se añade a esa cadena
        ## Añadir a cadena
        chains = Chains.find(gameId: move.gameId).fetch()
        chainId = ""
        for chain in chains
            #Arriba
            if chain.row is move.row - 1 and chain.column is move.column
                if chain.stone is move.stone
                    chainId = chain.chainId
                    console.log "Derecha"
            #Abajo
            if chain.row is move.row + 1 and chain.column is move.column
                if chain.stone is move.stone
                    chainId = chain.chainId
                    console.log "Izquierda"
            #Derecha
            if chain.row is move.row and chain.column is move.column + 1
                if chain.stone is move.stone
                    chainId = chain.chainId
                    console.log "Arriba"
            #Izquierda
            if chain.row is move.row and chain.column is move.column - 1
                if chain.stone is move.stone
                    chainId = chain.chainId
                    console.log "Abajo"
        
        #Si no pertenece a ninguna cadena, crear cadena nueva. Si pertenece, añadirla
        if chainId is ""
            Meteor.call "newChain", move
        else
            Meteor.call "updateChain", move, chainId

        
        #Eliminar cadenas que no tengan libertades y que no sea la cadena recien creada
        #Evitar eliminar la piedra recien puesta
        
        distinctChains = _.uniq(chains, false, (d) ->
            d.chainId
        )
        distinctValues = _.pluck(distinctChains, "chainId")
        
        totalChains = Chains.find().fetch()
        for id in distinctValues
            chains = Chains.find(chainId: id).fetch()
            deleteChain = true;
            for chain in chains
                freedoms = 4
                for tchain in totalChains
                    if tchain.row is chain.row - 1 and tchain.column is chain.column
                        freedoms -= 1
                    if tchain.row is chain.row + 1 and tchain.column is chain.column
                        freedoms -= 1
                    if tchain.row is chain.row and tchain.column is chain.column + 1
                        freedoms -= 1
                    if tchain.row is chain.row and tchain.column is chain.column - 1
                        freedoms -= 1
                if freedoms > 0
                    console.log "Cadena que se salva"
                    deleteChain = false;
            if deleteChain
                #ELiminar cadena
                console.log "Eliminar la cadena: " + id
                
                        
        #Ahora comprobamos explicitamente la cadena recien insertada para comprobar si es un suicidio y no permitirlo
        #Si existe suicidio, restaurar tablero
        
        #Insertar movimiento
        
        
        
        
        
        Moves.insert move
        return


