class Screen
  # @leds2d
  constructor: (@width, @height) ->
    @leds2d = []
    ledID = 0
    for row in [0...@height]
      @leds2d.push []
      for column in [0...@width]
        $('#atom-Snake-Game').append $("<div id=\"snake-Led-#{ledID}\" class=\"snake-Led\"></div>")
        @leds2d[row].push false
        ledID++
      $('#atom-Snake-Game').append $('<br>')

      

  render: () ->
    ledID = 0
    for row in [0...@height]
      for column in [0...@width]
        $("#snake-Led-#{ledID}").addClass 'snake-Led-On' if @leds2d[row][column] is on
        ledID++

        

  erase: () ->
    ledID = 0
    for row in [0...@height]
      for column in [0...@width]
        @leds2d[row][column] = off
        $("#snake-Led-#{ledID}").removeClass 'snake-Led-On'
        ledID++



  drawPixel: (x, y, status=true) ->
    @leds2d[y][x] = status





class AtomSnake

  #@snake: Array<Array<Int>>
  #@food: Array<Int>
  #@direction: Int
  #@screen: Screen
  #@playing: Boolean
  
  constructor: (@width, @height, @wall) ->
    @screen = new Screen @width, @height
    # key down event
    $(window).keyup (e) =>
      if e.keyCode is 38
        @direction = 3 if @direction isnt 1
      else if e.keyCode is 40
        @direction = 1 if @direction isnt 3
      else if e.keyCode is 37
        @direction = 2 if @direction isnt 0
      else if e.keyCode is 39
        @direction = 0 if @direction isnt 2
    $('.sbTop').click => @direction = 3 if @direction isnt 1
    $('.sbBottom').click => @direction = 1 if @direction isnt 3
    $('.sbLeft').click => @direction = 2 if @direction isnt 0
    $('.sbRight').click => @direction = 0 if @direction isnt 2

    # start game
    @startGame()

  startGame: () ->
    # init
    @snake = [[0, 2]]
    @direction = 0
    @playing = true
    @genFood()

    # main loop
    setTimeout @updateGame, 500

  updateGame: (setPos) =>
    if setPos is undefined
      # get next position
      if @direction is 0
        nextPos = [@snake[0][0]+1, @snake[0][1]]
      else if @direction is 1
        nextPos = [@snake[0][0], @snake[0][1]+1]
      else if @direction is 2
        nextPos = [@snake[0][0]-1, @snake[0][1]]
      else if @direction is 3
        nextPos = [@snake[0][0], @snake[0][1]-1]
    else
      nextPos = setPos

    # check if the snake hit the wall
    hitWall = true if nextPos[0] < 0 or nextPos[0] >= @width or nextPos[1] < 0 or nextPos[1] >= @height

    # check if the snake hit itself
    for i in @snake
      if i[0] is nextPos[0] and i[1] is nextPos[1]
        hitSelf = true

    # check if the snake eat the food
    eatFood = true if nextPos[0] is @food[0] and nextPos[1] is @food[1]


    # game logic
    if hitWall
      if @wall
        @endGame()
      else
        if nextPos[0] < 0
          nextPos[0] = @width - 1
        else if nextPos[1] < 0
          nextPos[1] = @height - 1
        else if nextPos[0] >= @width
          nextPos[0] = 0
        else if nextPos[1] >= @height
          nextPos[1] = 0
        @updateGame nextPos
        return
    else if hitSelf
      @endGame()
    else if eatFood
      @snake.unshift nextPos
      $('#eat')[0].play()
      if @snake.length is @width * @height
        @endGame()
      else
        @genFood()
    else
      @snake.unshift nextPos
      @snake.pop()
      $('#crawl')[0].play()

    if @playing
      # render
      @render()

      #looping
      setTimeout @updateGame, 500

  endGame: () ->
    @playing = false
    $('#hit')[0].play()
    @flashing @countScore
    

  genFood: () ->
    @food = [ Math.floor(Math.random()*@width), Math.floor(Math.random()*@height)]
    for i in @snake
      if i[0] is @food[0] and i[1] is @food[1]
        @genFood()
        break

  render: () ->
    @screen.erase()
    for i in @snake
      @screen.drawPixel i[0], i[1], true
    @screen.drawPixel @food[0], @food[1]
    @screen.render()

  flashing: (callBack) =>
    @screen.erase()
    @screen.render()
    setTimeout =>
      @render()
      setTimeout =>
        @screen.erase()
        @screen.render()
        setTimeout =>
          @render()
          setTimeout =>
            @screen.erase()
            @screen.render()
            setTimeout =>
              @render()
              setTimeout =>
                @screen.erase()
                callBack 0
              , 300
            ,300
          ,300
        ,300
      ,300
    ,300


  countScore: (showScore) =>
    if showScore < @snake.length
      $('#eat')[0].currentTime = 0
      $('#eat')[0].play()
      @screen.drawPixel showScore%5, Math.floor(showScore/5)
      @screen.render()
      setTimeout =>
        @countScore ++showScore
      , 300
    else
      setTimeout =>
        @startGame()
      , 2000
    
$(document).ready ->
  snakeGame = new AtomSnake(5, 5, false)


