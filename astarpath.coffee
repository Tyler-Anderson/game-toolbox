###------------------------------
    
    Created by Tyler Anderson
    github: Tyler-Anderson
    twitter: @_Bravado
    website: brava.do

------------------------------###
#currently setup as a proof of concept webworker for async pathfinding
class BinaryHeap
  constructor:(score_func)->
    @content = []
    @scoreFunction = score_func
  
  push: (element) ->
    @content.push element
    @sinkDown @content.length - 1

  pop: ->
    result = @content[0]
    end = @content.pop()
    if @content.length > 0
      @content[0] = end
      @bubbleUp 0
    result

  remove: (node) ->
    i = @content.indexOf(node)
    end = @content.pop()
    if i isnt @content.length - 1
      @content[i] = end
      if @scoreFunction(end) < @scoreFunction(node)
        @sinkDown i
      else
        @bubbleUp i

  size: ->
    @content.length

  rescoreElement: (node) ->
    @sinkDown @content.indexOf(node)

  sinkDown: (n) ->
    element = @content[n]
    while n > 0
      parentN = ((n + 1) >> 1) - 1
      parent = @content[parentN]
      if @scoreFunction(element) < @scoreFunction(parent)
        @content[parentN] = element
        @content[n] = parent
        n = parentN
      else
        break

  bubbleUp: (n) ->
    length = @content.length
    element = @content[n]
    elemScore = @scoreFunction(element)
    loop
      child2N = (n + 1) << 1
      child1N = child2N - 1
      swap = null
      if child1N < length
        child1 = @content[child1N]
        child1Score = @scoreFunction(child1)
        swap = child1N  if child1Score < elemScore
      if child2N < length
        child2 = @content[child2N]
        child2Score = @scoreFunction(child2)
        swap = child2N  if child2Score < (if swap is null then elemScore else child1Score)
      if swap isnt null
        @content[n] = @content[swap]
        @content[swap] = element
        n = swap
      else
        break
      
rand = ()->
  if Math.floor((Math.random()*8)) == 0
    1
  else
    0
rand1 = ->
  Math.floor((Math.random()*24))

#type = 0 is open, all others are closed
graphNode =( x, y, type = rand(), @data = {})->
  node = {x:x,y:y,type:type}

class Map
  constructor: (gridX,gridY) ->
    @g ?= []
    for x in [0...gridX]
      @g[x] ?= []
      for y in [0...gridY]
        @g[x][y] = new graphNode(x,y, rand())

class Path
  constructor:(@map) ->
    for x in [0...@map.length]
      for y in [0...@map[x].length]
        @grid ?= []
        @grid[x] ?= []
        @grid[x][y] ?= {}
        @grid[x][y].x = x
        @grid[x][y].y = y
        @grid[x][y].type = @map[x][y].type
        @grid[x][y].f = 0
        @grid[x][y].g = 0
        @grid[x][y].h = 0
        @grid[x][y].cost = 1
        @grid[x][y].visited = false
        @grid[x][y].closed = false
        @grid[x][y].parent = null

  heap: ->
    new BinaryHeap (node) -> node.f

  search:(start_x,start_y,goal_x,goal_y,diagonal = false)->
    end = @grid[goal_x][goal_y]
    @ret = null
    openHeap = @heap()
    openHeap.push @grid[start_x][start_y]

    while openHeap.size() > 0
      currentNode = openHeap.pop()
      if currentNode.x == end.x && currentNode.y == end.y
        curr = currentNode
        ret = []
        while curr.parent
          ret.push curr
          curr = curr.parent
        @ret = ret.reverse()

      currentNode.closed = true
      neighbors = @adjacent(currentNode,diagonal)
      for i in [0...neighbors.length]
        neighbor = neighbors[i]
        if(neighbor.closed == true || @grid[neighbor.x][neighbor.y].type != 0)
          continue

        beenVisited = neighbor.visited
        gScore = currentNode.g + neighbor.cost

        if(!beenVisited || gScore < neighbor.g)
          neighbor.visited = true
          neighbor.parent = currentNode
          neighbor.h = neighbor.cost * (Math.abs(neighbor.x - end.x) + Math.abs(neighbor.y - end.y))
          neighbor.g = gScore
          neighbor.f = neighbor.g + neighbor.h

        if !beenVisited
          openHeap.push neighbor
        else
          openHeap.rescoreElement neighbor
    return @ret

  adjacent:(cur,diagonals = false)->
    adj = []
    @checkAdj(cur,adj,0,1)
    @checkAdj(cur,adj,1,0)
    @checkAdj(cur,adj,-1,0)
    @checkAdj(cur,adj,0,-1)
    if diagonals == true
      @checkAdj(cur,adj,1,-1)
      @checkAdj(cur,adj,-1,-1)
      @checkAdj(cur,adj,1,1)
      @checkAdj(cur,adj,-1,1)
    return adj

  checkAdj:(cur,adj,x,y)->
    adj.push @grid[cur.x + x][cur.y + y] if @grid?[cur.x + x]?[cur.y + y]?

world = new Map(25,25)
find_path = (sx,sy,gx,gy,tileDim)->
  path = new Path(world.g)
  path_ret = path.search(sx,sy,gx,gy,false)
  path = null
  for i in [0...path_ret.length]
    path_ret[i].x *= (tileDim.x / world.g.length)
    path_ret[i].y *= (tileDim.y / world.g[0].length)
  path_ret
@world = world
@map = new Map(25,25)
@find_path = find_path


class Handler
  loadMap : (map) ->
    Handler::world = map
    self.postMessage 'loaded'
  findPath : (data) ->
    c = data.coords
    pathfinder = new Path @world.g
    pathRet = pathfinder.search c.startX, c.startY, c.goalX, c.goalY, false
    pathfinder = null
    self.postMessage pathRet

  destroy : (data) ->
    for k,v of data when k is tile
      world[v.x][v.y][v.z] = null
  build : (data) ->
    for k,v of data when k is tile
      v.z ?= 0
      world[v.x][v.y][v.z] = v.data

  dispatch : (e) ->
    data = e.data
    switch data.cmd
      when 'loadMap' then @loadMap data.map
      when 'build'   then @build data
      when 'findPath' then @findPath data

    ###findPath = (data) ->
  c = data.coords
  pathfinder = new Path data.world.g
  pathRet = pathfinder.search c.startX, c.startY, c.goalX, c.goalY, false
  pathfinder = null
  self.postMessage pathRet
#only removes item from map

dispatch = (e) ->
  data = e.data
  switch data.cmd
    when 'loadMap' then loadMap data.map
    when 'build'   then build data
    when 'findPath' then findPath data
  self.postMessage 'worky good'
  ###
handler = new Handler()
self.addEventListener 'message', (e) -> handler.dispatch(e)
self.addEventListener 'error', (e) -> console.log e
