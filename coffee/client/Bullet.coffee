class Bullet
  constructor:(@x,@y)->
    @speed=0
    @angle=0
    @width=image_repo.bullet.width
    @height=image_repo.bullet.height

  set:(x,y,angle,speed)=>
    @x=x
    @y=y
    @speed=if speed? then speed else 5
    @angle=if angle? then angle else 0

  draw:(cxt,bounds)=>    
    @y+=@speed*Math.sin(@angle)
    @x+=@speed*Math.cos(@angle)    
    # console.log('!! '+@y)
    if @y<=bounds[0].y-@height or @y>=bounds[1].y+@height or @x<=bounds[0].x-@width or @x>=bounds[1].x+@width
      # console.log('end '+@y)
      return true
    x=@x+image_repo.user_ship.width/2
    y=@y+image_repo.user_ship.height/2
    cxt.save()
    cxt.translate(x,y)
    cxt.rotate(@angle+Math.PI/2)
    cxt.fillStyle="green"
    cxt.fillRect(-@width/2,-@height/2,@width,@height)
    cxt.restore()
    false

  reset:()=>
    @x=@y=@speed=0