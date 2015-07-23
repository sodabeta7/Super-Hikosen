class Rock
  constructor:()->
    @x=0
    @y=0
    @z=Math.random()*1+0.3
    @size=1.2
    @opacity=Math.random()*0.8+0.1

  update:(bounds)=>
    if @x==0 or @y==0
      @x=Math.random()*(bounds[1].x-bounds[0].x)+bounds[0].x
      @y=Math.random()*(bounds[1].y-bounds[0].y)+bounds[0].y
    @x=if @x<bounds[0].x then bounds[1].x else @x
    @y=if @y<bounds[0].y then bounds[1].y else @y
    @x=if @x>bounds[1].x then bounds[0].x else @x
    @y=if @y>bounds[1].y then bounds[0].y else @y

  draw:(context)=>    
    context.fillStyle = 'rgba(226,219,226,'+@opacity+')'    
    context.beginPath()
    context.arc(@x,@y,@z*@size,0,Math.PI*2,true)
    context.closePath()
    context.fill()