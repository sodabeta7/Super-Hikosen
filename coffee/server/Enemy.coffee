BulletPool=require('./BulletPool')

grand=(min, max)->
  Math.random()*(max-min)+min

class Enemy
  constructor:(data)->
    @id=(new Date()).getTime()
    @x=data.x+grand(-500,500)
    @y=data.y+grand(-300,300)
    @health=200
    @bullet_pool=new BulletPool(100)    
    @max_momentum=1.0/36
    @momentum=0
    @width=38
    @height=28
    @angle=0
    @target_x=0
    @target_y=0
    @target_momentum=0
    @shoot_cnt=0

  update:(mouse)=>    
    # return
    # @x+=Math.min(Math.cos(@angle)*@momentum,(@target_x-@x)/120)
    # @y+=Math.min(Math.sin(@angle)*@momentum,(@target_y-@y)/120)
    # if @target_x!=0 or @target_y!=0
    #   @x+=(@target_x-@x)/120
    #   @y+=(@target_y-@y)/120
    # if @gdis(@x,@y,mouse.x,mouse.y)<@size+2
    #   @hover=true      
    # else
    #   @hover=false
    @bullet_pool.update(@x,@y)
    # console.log('x is '+@x+' y is '+@y)
    # @bullet_pool.prt()
  
  userUpdate:(angle_tx,angle_ty)=>
    @target_x=angle_tx
    @target_y=angle_ty    
    @angle=Enemy.calAngle(@x,@y,angle_tx,angle_ty)        
    
  
  shoot:()=>
    @bullet_pool.get(@x,@y,@angle)

  @calAngle:(x1,y1,x2,y2)->
    Math.atan2(y2-y1,x2-x1)

  @normalAngle:(x)->
    while x<-Math.PI
      x+=2*Math.PI
    while x>Math.PI
      x-=2*Math.PI
    x

  gdis:(x1,y1,x2,y2)=>
    Math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2))

  prt:()=>
    p=console.log
    p('position '+@x+' '+@y)


module.exports=exports=Enemy




