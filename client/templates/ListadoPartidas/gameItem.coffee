id = undefined

Template.gameItem.helpers
    propietario: ->
        @userId is Meteor.userId()

    id: ->
        id = @_id
        @_id
        
Template.gameItem.rendered = ->
    id = this.$("canvas").attr("id")
    NUMBER_OF_COLS = 19
    NUMBER_OF_ROWS = 19
    canvas = this.find "canvas"
    ctx = canvas.getContext("2d")
    BLOCK_SIZE = canvas.height / NUMBER_OF_ROWS
    moves = Moves.find(gameId: id).fetch()
    color = null
    turno = false
    h = 200
    w = 200
    img_black = new Image()
    img_black.src = "/img/pieces_black.png"
    img_white = new Image()
    img_white.src = "/img/pieces_white.png"
    tamStone = parseInt(w / NUMBER_OF_ROWS)
    
    draw= ->
        canvas = this.$('canvas#'+id)[0]
        ctx = canvas.getContext("2d")
        drawBoard()
        drawLines()
        drawStones()
        return
    
    drawBoard= ->
        ctx.fillStyle = "#F7F8E0"
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
        ctx.arc (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, 3, 0, 2 * Math.PI, true
        ctx.fill()
        ctx.beginPath()
        ctx.arc (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, 3, 0, 2 * Math.PI, true
        ctx.fill()
        ctx.beginPath()
        ctx.arc (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, 3, 0, 2 * Math.PI, true
        ctx.fill()
        ctx.beginPath()
        ctx.arc (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, 3, 0, 2 * Math.PI, true
        ctx.fill()
        ctx.beginPath()
        ctx.arc (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, 3, 0, 2 * Math.PI, true
        ctx.fill()
        ctx.beginPath()
        ctx.arc (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, 3, 0, 2 * Math.PI, true
        ctx.fill()
        ctx.beginPath()
        ctx.arc (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, 3, 0, 2 * Math.PI, true
        ctx.fill()
        ctx.beginPath()
        ctx.arc (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, 3, 0, 2 * Math.PI, true
        ctx.fill()
        ctx.beginPath()
        ctx.arc (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, 3, 0, 2 * Math.PI, true
        ctx.fill()
        return
  
    drawStones= -> 
        for move in moves
            ctx.drawImage img_black, move.row * BLOCK_SIZE, move.column * BLOCK_SIZE, tamStone, tamStone
        return
    
    $("canvas").each (index) ->
        id = $(this).attr("id")
        moves = Moves.find(gameId: id).fetch()
        draw()    
        
    Deps.autorun ->
        $("canvas").each (index) ->
            id = $(this).attr("id")
            moves = Moves.find(gameId: id).fetch()
            draw()
            return
        