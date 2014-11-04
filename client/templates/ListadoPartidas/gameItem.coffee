id = undefined
tmpl = undefined

Template.gameItem.created = ->
    console.log "hola"
    tmpl = this
    console.log this.find(@_id)

Template.gameItem.helpers
    propietario: ->
        @userId is Meteor.userId()

    id: ->
        id = @_id
        @_id
  
    tablero: ->
        console.log "ID ES: " + id
        console.log "template: " + tmpl
        NUMBER_OF_COLS = 19
        NUMBER_OF_ROWS = 19
        canvas = tmpl.$('#' + id)
        #canvas = document.getElementById(id)
        ctx = canvas.getContext("2d")
        container = $(canvas).parent()
        BLOCK_SIZE = canvas.height / NUMBER_OF_ROWS
        moves = Moves.find(gameId: id).fetch()
        color = null
        turno = false
        h = parseInt(document.getElementById(id).getAttribute("height"))
        w = parseInt(document.getElementById(id).getAttribute("width"))
        img_black = new Image()
        img_black.src = "/img/pieces_black.png"
        img_white = new Image()
        img_white.src = "/img/pieces_white.png"
        tamStone = parseInt(w / NUMBER_OF_ROWS)
        window.addEventListener("resize", (e) => respondCanvas(e))
        
        respondCanvas= (e) ->
            canvas.setAttribute("width", $(container).width())
            BLOCK_SIZE = $(container).width()/ NUMBER_OF_ROWS
            canvas.setAttribute("height", BLOCK_SIZE * NUMBER_OF_ROWS) 
            h = BLOCK_SIZE * NUMBER_OF_ROWS
            w = parseInt($(container).width())
            console.log "h: " + h
            console.log "w: " + w
            tamStone = parseInt(w / NUMBER_OF_ROWS)
            draw()
            return
        
        draw= ->
            drawBoard()
            drawLines()
            drawStones()
            return
        
        drawBoard= ->
            ctx.fillStyle = "#FBF6D5"
            ctx.fillRect 0, 0, w, h
            return
        
        drawLines= ->
            #Pintamos las lineas horizontales
            iRowCounter = 0
            while iRowCounter < NUMBER_OF_ROWS
                ctx.strokeStyle = "#000000"
                ctx.beginPath()
                ctx.moveTo BLOCK_SIZE / 2, (iRowCounter * BLOCK_SIZE) + (BLOCK_SIZE / 2)
                ctx.lineTo (NUMBER_OF_COLS * BLOCK_SIZE) - (BLOCK_SIZE / 2), (iRowCounter * BLOCK_SIZE) + (BLOCK_SIZE / 2)
                ctx.stroke()
                iRowCounter++
        
            #Pintamos las lineas verticales
            iColCounter = 0
            while iColCounter < NUMBER_OF_COLS
                ctx.strokeStyle = "#000000"
                ctx.beginPath()
                ctx.moveTo (iColCounter * BLOCK_SIZE) + (BLOCK_SIZE / 2), BLOCK_SIZE / 2
                ctx.lineTo (iColCounter * BLOCK_SIZE) + (BLOCK_SIZE / 2), (NUMBER_OF_ROWS * BLOCK_SIZE) - (BLOCK_SIZE / 2)
                ctx.stroke()
                iColCounter++
            #Pintamos los Hoshi y el Tengen
            ctx.beginPath()
            ctx.fillStyle = "#000000"
            ctx.arc (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true
            ctx.fill()
            ctx.beginPath()
            ctx.arc (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true
            ctx.fill()
            ctx.beginPath()
            ctx.arc (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true
            ctx.fill()
            ctx.beginPath()
            ctx.arc (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true
            ctx.fill()
            ctx.beginPath()
            ctx.arc (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true
            ctx.fill()
            ctx.beginPath()
            ctx.arc (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true
            ctx.fill()
            ctx.beginPath()
            ctx.arc (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true
            ctx.fill()
            ctx.beginPath()
            ctx.arc (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true
            ctx.fill()
            ctx.beginPath()
            ctx.arc (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true
            ctx.fill()
            return
      
        drawStones= ->        
            for move in moves
                ctx.drawImage img_black, move.row * BLOCK_SIZE, move.column * BLOCK_SIZE, tamStone, tamStone
            return
