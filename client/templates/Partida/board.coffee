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
    canvas.setAttribute("width", $(container).width())
    canvas.addEventListener("click", (e) => OnClick(e))
    canvas.addEventListener("mousemove", (e) => mouseMove(e))
    BLOCK_SIZE = $(container).width()/ NUMBER_OF_ROWS
    canvas.setAttribute("height", BLOCK_SIZE * NUMBER_OF_ROWS)
    stones = Stones.find(gameId: id).fetch()
    game = Games.find(_id: id).fetch()[0]
    blockMove = false
    h = BLOCK_SIZE * NUMBER_OF_ROWS
    w = parseInt($(container).width())
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
        tamStone = parseInt(w / NUMBER_OF_ROWS)
        draw()
        return

    draw= ->
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
        for stone in stones
            ctx.drawImage img_black, stone.row * BLOCK_SIZE, stone.column * BLOCK_SIZE, tamStone, tamStone if stone.stone is 'b' and stone.validMove is true
            ctx.drawImage img_white, stone.row * BLOCK_SIZE, stone.column * BLOCK_SIZE, tamStone, tamStone if stone.stone is 'w' and stone.validMove is true
        return

    OnClick= (e) ->
        #lastMove = Moves.find {gameId:id},
        #            sort:
        #                submitted: -1
        #            limit: 1
        #console.log lastMove.fetch()[0]._id

        #Comprobamos si es nuestro turno
        game = Games.find(_id: id).fetch()[0]
        turn = game.turn
        user = Meteor.user().profile.Usuario

        if user is turn and game.finalized is false
            #Evitamos que se puedan poner piezas varias veces en el intervalo de procesamiento de jugadas del servidor
            if blockMove is false
                blockMove = true
                cell = getCursorPosition(e)

                #Determinamos el color de la piedra
                if user is game.player1
                    myStone = 'b'
                else
                    myStone = 'w'

                move =
                    gameId: id
                    column: cell.Column
                    row: cell.Row
                    submitted: new Date().getTime()
                    stone: myStone
                    player: game.turn
                Meteor.call "newMove", move, (err, result) ->
                    if err
                        console.log "No se puede enviar la jugada " + err.reason
                    else
                        if result
                            Meteor.call "changeTurn", game, (err, result) ->
                                if err
                                    console.log "Error al pasar el turno"
                                else
                                    blockMove = false
                        else
                            blockMove = false
                    return
                draw()
            return

    mouseMove= (e) ->
        if game.finalized is false
            draw()
            user = Meteor.user().profile.Usuario
            offset = $("#" + id).offset()
            x = e.pageX - offset.left
            y = e.pageY - offset.top
            row = Math.floor(x / BLOCK_SIZE)
            column = Math.floor(y / BLOCK_SIZE)
            posX = (row * BLOCK_SIZE) + (BLOCK_SIZE / 2)
            posY = (column * BLOCK_SIZE) + (BLOCK_SIZE / 2)
            ctx.beginPath()
            ctx.arc posX, posY, tamStone / 2, 0, 2 * Math.PI, true
            if user is game.player1
                ctx.fillStyle = "black"
                ctx.globalAlpha = 0.5
            else
                ctx.fillStyle = "white"
                ctx.globalAlpha = 0.9
            ctx.lineWidth = 2
            ctx.strokeStyle = 'black'
            ctx.stroke()
            ctx.fill()
            ctx.globalAlpha = 1.0
            ctx.lineWidth = 1
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
        stones = Stones.find(gameId: id).fetch()
        draw()

return
