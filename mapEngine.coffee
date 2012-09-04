###------------------------------
    Unfinished map engine

    Created by Tyler Anderson
    github: Tyler-Anderson
    twitter: @_Bravado
    website: brava.do

------------------------------###
#to be named tiled map engine

#type = 0 is open, all others are closed

tile = (args...)->
  @data = {}
  if args.length == 2
    {x:x, y:y, @data}
  else if args.length == 3
    {x:x, y:y, z:z, @data}
  else false

#projection is either  flat, or isometric for now
# usage tileMap(type, x, y) for 2d, tileMap(type, x, y, z) for 3d
tileMap = (args...) ->
  @map = []
  @projection = args[0] ? 'flat'
  if args.length == 3
    for x in [0...xLength]
      @map[x] ?= []
      for y in [0...yLength]
        @map[x][y] = new tile(x,y)
  else if args.length == 4
    for x in [0...xLength]
      @map[x] ?= []
      for y in [0...yLength]
        @map[x][y] ?= []
        for z in [0...zLength]
          @map[x][y][z] = new tile(x,y,z)


class AssetSheet
  constructor:(@raw) ->
    @dict = []

  sliceTile:(layout)->
    images = []
    xCount = -1
    yCount = -1
    xStop = layout.xStop ? @raw.width
    yStop = layout.yStop ? @raw.height
    xPadding = layout.xPadding ? 0
    yPadding = layout.yPadding ? 0
    for x in [layout.xOffset...xStop] by layout.xSpacing
      images[x] ?= 0
      xCount++
      for y in [layout.yOffset...yStop] by layout.ySpacing
        yCount++
        end.x = x + layout.xSpacing + layout.xPadding
        end.y = y + layout.ySpacing + layout.yPadding
        images[xCount][yCount] =
          xStart:x
          yStart:y
          xEnd:end.x
          yEnd:end.y
    return images

  sliceManual:(layout)->
    for key, value of layout.name
      images[key] = value
    @cache(images)

  sliceSprite:(layout)->
    xPadding = layout.xPadding ? 0
    yPadding = layout.yPadding ? 0
    for key, value of layout.sequence
      @images[key] = []
      value.dir ?= 'horizontal'
      if value.dir = 'vertical'
        for y in [layout.yOffset...layout.yEnd] by ySpacing
          end.y = y + layout.ySpacing + layout.yPadding
          @images[key].push
            yStart:y
            xStart:yOffset
            yEnd  :end.y
            xEnd  :xOffset
      else
        for y in [layout.xOffset...layout.xEnd] by xSpacing
          end.x = x + layout.xSpacing + layout.xPadding
          @images[key].push
            xStart:x
            yStart:yOffset
            xEnd  :end.x
            yEnd  :yOffset
      spriteAuto:(spriteSheet)->
        
