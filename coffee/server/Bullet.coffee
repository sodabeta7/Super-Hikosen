class Bullet
  constructor:(@x,@y)->
    @speed=0
    @angle=0    

  set:(x,y,angle,speed)=>
    @x=x
    @y=y
    @speed=if speed? then speed else 6
    @angle=if angle? then angle else 0

  update:()=>
    @y+=@speed*Math.sin(@angle)
    @x+=@speed*Math.cos(@angle)    

  reset:()=>
    @x=@y=@speed=0

  prt:()=>
    console.log(@x+' '+@y)

module.exports=exports=Bullet