###-------------------------------------------

    Coffeescript quadtree implementation

    Tyler Anderson
    github  : Tyler-Anderson
    twitter : @_Bravado
    website : brava.do

-------------------------------------------###

# guesses for maxDepth and children, fix them later
class QuadTree
    constructor:(bounds, pointQuad, maxDepth, maxChildren) ->
        console.log this
        if pointQuad == true then node = new Node(bounds, 0,maxDepth, maxChildren)
        else
            node = new BoundsNode(bounds, 0, maxDepth,maxChildren)
        @root = node

    insert : (item) ->
        if item instanceof Array
            for i in [0...item.length]
                @root.insert item[i]
        else
            @root.insert item
    clear:->
        @root.clear()
    retrieve: (item) ->
        @root.retrieve(item).slice(0)

class Node
    constructor:(@_bounds, @_depth, @_maxDepth = 7, @_maxChildren = 4) ->
        @nodes = []
        @children = []
        _maxChildren   : 4
        _maxDepth: 4
        TOP_LEFT : 0
        TOP_RIGHT : 1
        BOTTOM_LEFT : 2
        BOTTOM_RIGHT : 3

    _classConstructor: Node

    insert : (item) ->
        if @nodes.length
            index = @_findIndex(item)
            @nodes[index].insert(item)

        @children.push item
        len = @children.length
        if  @_depth >= @_maxDepth and len > @_maxChildren
            @subdivide()
            for i in [i...len]
                @insert @children[i]
            @children.length = 0

    retrieve : (item) ->
        if @nodes.length
            index = @_findIndex(item)
            @nodes[index].retrieve(item)
        @children

    _findIndex : (item) ->
        b     = @_bounds
        left  = (if (item?.x > b.x + b.width  / 2) then false else true)
        top   = (if (item?.y > b.y + b.height / 2) then false else true)
        index = @TOP_LEFT
        if left
            index = @BOTTOM_LEFT unless top
        else
            if top
                index = @TOP_RIGHT
            else
                index = @BOTTOM_RIGHT
        index

    subdivide: ->
        depth     = @_depth + 1
        bx        = @_bounds.x
        by_       = @_bounds.y
        b_w_h     = (@_bounds.width / 2) | 0
        b_h_h     = (@_bounds.height/ 2) | 0
        bx_b_w_h  = bx + b_w_h
        by_b_h_h  = by_ + b_h_h
        @nodes[@TOP_LEFT] = new @_classConstructor(
            x: bx
            y: by_
            width: b_w_h
            height:b_h_h
            , depth)
        @nodes[@TOP_RIGHT] = new @_classConstructor(
            x: bx_b_w_h
            y: by_
            width: b_w_h
            height: b_h_h
            , depth)
        @nodes[@BOTTOM_LEFT] = new @_classConstructor(
            x: bx
            y: by_b_h_h
            width: b_w_h
            height: b_h_h
            , depth)
        @nodes[@BOTTOM_RIGHT] = new @_classConstructor(
            x: bx_b_w_h
            y: by_b_h_h
            width: b_w_h
            height: b_h_h
            , depth)


    clear : ->
        @children.length = 0
        len = @nodes.length
        for i in [0...len]
            @nodes[i].clear()
        @nodes.length = 0

class BoundsNode extends Node
    constructor:(@_bounds, @_depth, @_maxDepth = 4, @_maxChildren = 4)->
        Node.call(this,@_bounds, @_depth, @_maxDepth, @_maxChildren)
    _classConstructor: BoundsNode
    _stuckChildren : []

    insert: (item) ->
        if @nodes.length
            index = @_findIndex(item)
            node = @nodes[index]

            if(item.x >= node._bounds.x and
                item.x + item.width <= node._bounds.x + node._bounds.width and
                item.y >= node._bounds.y and
                item.y + item.height <= node._bounds.y + node._bounds.height)
                    @nodes[index].insert item
                else
                    @_stuckChildren.push item

        @children.push item
        len = @children.length
        if @_depth >= @_maxDepth and len > @_maxChildren
            @subdivide()
            for i in [0...len]
                @insert @children[i]
            @children.length = 0


#BoundsNode::_stuckChildren = null
    getChildren: ->
        @children.concat( @_stuckChildren )

    retrieve: (item) ->
        out = @_out
        out.length = 0
        if @nodes.length
            index = @_findIndex(item)
            out.push.apply(out, @nodes[index].retrieve(item))
        out.push.apply(out, @_stuckChildren)
        out.push.apply(out, @children)
        out
    clear : ->
        @_stuckChildren.length = 0
        @children.length = 0
        len = @nodes.length
        if(!len) then return
        for i in [0...len - 1]
            @nodes[i].clear()
        @nodes.length = 0
BoundsNode.prototype._classConstructor = BoundsNode
BoundsNode.prototype._out = []
@QuadTree = QuadTree
