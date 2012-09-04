###------------------------------
    
    Created by Tyler Anderson
    github: Tyler-Anderson
    twitter: @_Bravado
    website: brava.do

------------------------------
  Unit::changePath = (path)->
    @stop = true
    @path = path
    @count = 0
    @stop = false
    @destruct = false
    ###

$ ->
  rand = ->
    if Math.floor((Math.random()*5)) == 0
      1
    else
     0
  
  rand1 = ->
    Math.floor((Math.random()*24))

  cw = 1200
  ch = 1200
  offset = 0
  xLength = cw / world.g.length
  yLength = ch / world.g[0].length
  mainCanvas =  $("#layer1").attr({width:cw ,height:ch,top:'0px',left:'0px'}).appendTo('body')
  stage = new Stage mainCanvas.get(0)
  Ticker.addListener(stage)
  Ticker.useRAF = true
  Ticker.setFPS(60)
  bm = new Bitmap './img/gary.png'
  #bm.scaleY = 0.5
  bWall= new Bitmap './img/marioblock.png'
  #bWall.scaleY = 0.5
  #bWall.rotation = 45
  units = []

  testType =
    typeId: 1
    anim: bm.clone()

  eDistance = (x1,y1,x2,y2) ->
    x = x1 - x2
    y = y1 - y2
    Math.sqrt (x * x) + (y * y)

  ###
  start Unit baseclass
  ###

  class Unit
    constructor: (@type,@spawnPoint,@path)->
      @count = 0
      @baseSpeed = 300
      @x = @path[@count].parent.x * xLength
      @y = @path[@count].parent.y * yLength

  #clone the actual display element
  Unit:: = bm.clone()

  #start class movement functions
  Unit::moveRight = ->
    if @distX <= timer.pixelsPerFrame(window.time,@baseSpeed)
      @x = @path[@count].x
      @moveCalc()
      if @path[@count + 1]?
        @count++
      else escape(this)
      @moveCalc()
    else
      @x += timer.pixelsPerFrame(window.time,@baseSpeed)
      @distX -= timer.pixelsPerFrame(window.time,@baseSpeed)

  Unit::moveLeft = ->
    if @distX >= -timer.pixelsPerFrame(window.time,@baseSpeed)
      @x = @path[@count].x
      @moveCalc()
      if @path[@count + 1]?
        @count++
      else escape(this)
      @moveCalc()
    else
      @x += -timer.pixelsPerFrame(window.time,@baseSpeed)
      @distX += timer.pixelsPerFrame(window.time,@baseSpeed)

  Unit::moveDown= ->
    if @distY <= timer.pixelsPerFrame(window.time,@baseSpeed)
      @y = @path[@count].y
      if @path[@count + 1]?
        @count++
      else escape(this)
      @moveCalc()
    else
      @y += timer.pixelsPerFrame(window.time,@baseSpeed)
      @distY -= timer.pixelsPerFrame(window.time,@baseSpeed)

  Unit::moveUp= ->
    if @distY >= -timer.pixelsPerFrame(window.time,@baseSpeed)
      @y = @path[@count].y
      @moveCalc()
      if @path[@count + 1]?
        @count++
      else escape(this)
      @moveCalc()
    else
      @y += -timer.pixelsPerFrame(window.time,@baseSpeed)
      @distY += timer.pixelsPerFrame(window.time,@baseSpeed)

  Unit::move = ->
    if @moving? then @moving()
    else
      @moveCalc()

  Unit::moveCalc = ->
    @distX = @path[@count].x - @x
    @distY = @path[@count].y - @y
    if @path[@count].x > @x
      @moving = ->
        @moveRight()
    if @path[@count].x < @x
      @moving = ->
        @moveLeft()
    if @path[@count].y > @y
      @moving = ->
        @moveDown()
    if @path[@count].y < @y
      @moving = ->
        @moveUp()

  #end unit movement functions

  Unit::onTick = ->
    @move()

  ###
  end Unit baseclass
  start Unit factory
  ###

  
  escape = (unit)->
    stage.removeChild(unit)
    unit = null
    
  unitFactory = ()->
    pos = (units.push new Unit(testType,testSpawn(),myPath) - 1)
    units[pos]:: bWall.clone()

  ###
  wall functions
  ###
  class WallController
  wall =(x,y) ->
    basicWall = bWall.clone()
    basicWall.x = x
    basicWall.y = y
    stage.addChild(basicWall)

  for x in [0...world.g.length]
    for y in [0...world.g[x].length]
      if world.g[x][y].type == 1
        wall(x * xLength, y * yLength)
  
  spawnObj = {x:0,y:15}

  addWalls = ->
    for i in [0...23]
      world.g[10][i].type = 1
      wall(10 * xLength, i * yLength)

  spawn = ->
    units.push new Unit(testType,spawnObj,myPath3)
    stage.addChild units[units.length - 1]

  newPath = ->
    window.myPath3 = find_path 0,15,23,2,{x:cw,y:ch},true

  setTimeout(newPath,800)
  setTimeout(addWalls,500)
  setInterval(spawn, 1000)
  
  fpsText = new Text("0","bold 96px Arial","gray")
  fpsText.x = 10
  fpsText.y = 100
  stage.addChild(fpsText)

  displayTime = ->
    fpsText.text = Ticker.getMeasuredFPS()

  setInterval(displayTime,250)
  stage.tick = ->
    window.time = timer.getTimeNow()
    timer.tock(window.time)
    stage.update()
