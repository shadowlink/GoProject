Template.topList.helpers games: ->
  Games.find {finalized: false},
    sort:
      submitted: -1
    limit: 4

Template.topList.rendered = ->
	Session.set("currentRoomId", "topList")	
	window.addEventListener("resize", (e) => respondCanvas(e))
	$(".topList").height( $( window ).height() - 260 )

	respondCanvas = (e) ->
		$(".topList").height( $( window ).height() - 260 )
		return