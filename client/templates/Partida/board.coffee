id = undefined
Template.board.helpers id: ->
    id = @_id
    @_id

Template.board.rendered = ->

    NUMBER_OF_COLS = 19
    NUMBER_OF_ROWS = 19
    canvas = document.getElementById(id)
    ctx = canvas.getContext("2d")
    container = $(canvas).parent()
    canvas.addEventListener("click", (e) => OnClick(e))
    canvas.addEventListener("mousemove", (e) => mouseMove(e))
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
    draw()
    
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

    OnClick= (e) ->
        cell = getCursorPosition(e)
        move =
            gameId: id
            column: cell.Column
            row: cell.Row
        Meteor.call "newMove", move, (err, result) ->
            console.log "No se puede enviar la jugada " + err.reason  if err
            return
        draw()
        return

    mouseMove= (e) ->
        draw()
        x = undefined
        y = undefined
        offset = $("#" + id).offset()
        x = e.pageX - offset.left
        y = e.pageY - offset.top
        row = undefined
        column = undefined
        posX = undefined
        posY = undefined
        row = Math.floor(x / BLOCK_SIZE)
        column = Math.floor(y / BLOCK_SIZE)
        posX = (row * BLOCK_SIZE) + (BLOCK_SIZE / 2)
        posY = (column * BLOCK_SIZE) + (BLOCK_SIZE / 2)
        ctx.beginPath()
        ctx.globalAlpha = 0.5
        if color is "b"
            ctx.fillStyle = "rgba(0, 0, 0)"
        else ctx.fillStyle = "rgba(255, 255, 255)"  if color is "w"
        ctx.arc posX, posY, tamStone / 2, 0, 2 * Math.PI, true
        ctx.fill()
        ctx.globalAlpha = 1.0
        return

    getCursorPosition= (e) ->
        x = undefined
        y = undefined
        offset = $("#" + id).offset()
        x = e.pageX - offset.left
        y = e.pageY - offset.top
        #obtener la posicion de dibujado de la piedra
        row = undefined
        column = undefined
        posX = undefined
        posY = undefined
        row = Math.floor(x / BLOCK_SIZE)
        column = Math.floor(y / BLOCK_SIZE)
        posX = (row * BLOCK_SIZE) + (BLOCK_SIZE / 2)
        posY = (column * BLOCK_SIZE) + (BLOCK_SIZE / 2)
        cell = new Object()
        cell.X = posX
        cell.Y = posY
        cell.Row = row
        cell.Column = column
        cell

    #Funciones auxiliares
    Deps.autorun ->
        moves = Moves.find(gameId: id).fetch()
        draw()

return
