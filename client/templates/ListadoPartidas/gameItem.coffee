Template.gameItem.helpers
  propietario: ->
    @userId is Meteor.userId()

  id: ->
    @_id

  domain: ->
    a = document.createElement("a")
    a.href = @url
    a.hostname

  tablero: ->


#id = this._id
#        console.log("ID es: " + id);
#        var jugadas = Jugadas.find({
#            partidaId: id
#        });
#        var color = null;
#        var turno = false;
#        var NUMBER_OF_COLS = 19,
#            NUMBER_OF_ROWS = 19,
#            BLOCK_SIZE = 100;
#        var h = parseInt(document.getElementById('"'+id+'"').getAttribute("height"));
#        var w = parseInt(document.getElementById('"'+id+'"').getAttribute("width"));
#        var img_black = new Image();
#        img_black.src = "/img/pieces_black.png";
#        var img_white = new Image();
#        img_white.src = "/img/pieces_white.png";
#        //-------------PINTADO JUEGO-----------------//
#        draw();
#
#        function draw() {
#            // Main entry point got the HTML5 chess board example
#            canvas = document.getElementById(id);
#            // Canvas supported?
#            if(canvas.getContext) {
#                ctx = canvas.getContext('2d');
#                // Calculate the precise block size
#                BLOCK_SIZE = canvas.height / NUMBER_OF_ROWS;
#                // Draw the background
#                drawBoard();
#                drawLines();
#                drawPiedras();
#            } else {
#                alert("Canvas not supported!");
#            }
#        }
#
#        function drawBoard() {
#            ctx.fillStyle = "#F3E2A9";
#            ctx.fillRect(0, 0, w, h);
#        }
#
#        function drawLines() {
#            //Pintamos las lineas horizontales
#            for(iRowCounter = 0; iRowCounter < NUMBER_OF_ROWS; iRowCounter++) {
#                ctx.strokeStyle = '#000000';
#                ctx.beginPath();
#                ctx.moveTo(BLOCK_SIZE / 2, (iRowCounter * BLOCK_SIZE) + (BLOCK_SIZE / 2));
#                ctx.lineTo((NUMBER_OF_COLS * BLOCK_SIZE) - (BLOCK_SIZE / 2), (iRowCounter * BLOCK_SIZE) + (BLOCK_SIZE / 2));
#                ctx.stroke();
#            }
#            //Pintamos las lineas verticlaes
#            for(iColCounter = 0; iColCounter < NUMBER_OF_COLS; iColCounter++) {
#                ctx.strokeStyle = '#000000';
#                ctx.beginPath();
#                ctx.moveTo((iColCounter * BLOCK_SIZE) + (BLOCK_SIZE / 2), BLOCK_SIZE / 2);
#                ctx.lineTo((iColCounter * BLOCK_SIZE) + (BLOCK_SIZE / 2), (NUMBER_OF_ROWS * BLOCK_SIZE) - (BLOCK_SIZE / 2));
#                ctx.stroke();
#            }
#            //Pintamos los Hoshi y el Tengen
#            ctx.beginPath();
#            ctx.fillStyle = '#000000';
#            ctx.arc((9 * BLOCK_SIZE) + BLOCK_SIZE / 2, (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true);
#            ctx.fill();
#            ctx.beginPath();
#            ctx.arc((3 * BLOCK_SIZE) + BLOCK_SIZE / 2, (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true);
#            ctx.fill();
#            ctx.beginPath();
#            ctx.arc((15 * BLOCK_SIZE) + BLOCK_SIZE / 2, (9 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true);
#            ctx.fill();
#            ctx.beginPath();
#            ctx.arc((3 * BLOCK_SIZE) + BLOCK_SIZE / 2, (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true);
#            ctx.fill();
#            ctx.beginPath();
#            ctx.arc((15 * BLOCK_SIZE) + BLOCK_SIZE / 2, (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true);
#            ctx.fill();
#            ctx.beginPath();
#            ctx.arc((9 * BLOCK_SIZE) + BLOCK_SIZE / 2, (3 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true);
#            ctx.fill();
#            ctx.beginPath();
#            ctx.arc((3 * BLOCK_SIZE) + BLOCK_SIZE / 2, (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true);
#            ctx.fill();
#            ctx.beginPath();
#            ctx.arc((15 * BLOCK_SIZE) + BLOCK_SIZE / 2, (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true);
#            ctx.fill();
#            ctx.beginPath();
#            ctx.arc((9 * BLOCK_SIZE) + BLOCK_SIZE / 2, (15 * BLOCK_SIZE) + BLOCK_SIZE / 2, 5, 0, 2 * Math.PI, true);
#            ctx.fill();
#        }
#
#        function drawPiedras() {
#            jugadas.forEach(function(jugada) {
#                ctx.drawImage(img_black, jugada.fila * BLOCK_SIZE, jugada.columna * BLOCK_SIZE);
#            });
#        }
Template.gameItem.rendered = ->

#Funciones auxiliares
#Deps.autorun(function() {
#        console.log("Repintado de " + id);
#        jugadas = Jugadas.find({
#            partidaId: id
#        });
#        draw();
#    });
