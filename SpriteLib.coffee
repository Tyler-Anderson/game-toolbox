###------------------------------
    
    Created by Tyler Anderson
    github: Tyler-Anderson
    twitter: @_Bravado
    website: brava.do

------------------------------###

class ImagePainter
    constructor : (imageUrl) ->
        @image = new Image
        @image.src = imageUrl

    paint : (sprite, context) ->
        if @image isnt undefined
            if not @image.complete
                @image.onload = (e) ->
                    sprite.width = @width
                    sprite.height = @height

                    context.drawImage this,
                                      sprite.left
                                      sprite.top
                                      sprite.width
                                      sprite.height
            else
                context.drawImage this,
                                  sprite.left
                                  sprite.top
                                  sprite.width
                                  sprite.height


class SpriteSheetPainter
    constructor : (@cells) ->
    cells : []
    cellIndex : 0

    advance : ->
        #arrays start at 0, length starts at 1
        if @cellIndex == @cells.length - 1
            @cellIndex = 0
        else
            @cellIndex++
    paint : (sprite, context) ->
        cell = @cells[@cellIndex]
        context.drawImage spritesheet,
                          cell.left
                          cell.top
                          cell.width
                          cell.height
                          sprite.left
                          sprite.top
                          cell.width
                          cell.height


class SpriteAnimator
    constructor : (@painters, @elapsedCallback) ->

    painters : []
    duration : 1000
    startTime : 0
    index : 0

    end : (sprite, originalPainter) ->
        sprite.animating = false
        @elapsedCallback?(sprite) ? sprite.painter = originalPainter

    start: (sprite, duration) ->
        endTime = +new Date() + duration
        period = duration / @painters.length
        #interval = undefined
        animator = this
        originalPainter = sprite.painter

        @index = 0
        sprite.animating = true
        sprite.painter = @painters[@index]

        # I don't like using inlined anon functions for setInterval
        interval_block ->
            if +new Date() < endTime
                sprite.painter = animator.painters[++animator.index]
            else
                animator.end sprite, originalPainter
                clearInterval(interval)

        interval = setInterval interval_block, period

class Sprite
    constructor : (@name, @painter, @behaviors) ->
        this

    left : 0
    top : 0
    width : 10
    height : 10
    velocityX : 0
    velocityY : 0
    visible : true
    animating : false
    behaviors : []

    paint : (context) ->
        @painter.paint this, context if @visible

    update : (context, time) ->
        for i in [@behaviors.length...0]
            @behaviors[i].execute this, context, time
