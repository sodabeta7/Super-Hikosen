class Arrow
  constructor:(@user,@camera)->
    @x=0
    @y=0
    @angle=0
    @dis=10
    @opacity=1

  update:()=>
    @angle=Math.atan2(@y-@camera.y,@x-@camera.x)

  draw:(context,canvas)=>
    camera_bounds=@camera.getBounds()
    if @user.x<camera_bounds[0].x or @user.y<camera_bounds[0].y or @user.x>camera_bounds[1].x or @user.y>camera_bounds[1].y
      size=4
      arrow_dis=100
      angle=@angle
      w=canvas.width/2-10
      h=canvas.height/2-10
      aa=Math.atan(h/w)
      ss=Math.cos(angle)
      cc=Math.sin(angle)
      if (Math.abs(angle)+aa)%Math.PI / 2 < aa
        arrow_dis=w/Math.abs(ss)
      else
        arrow_dis=h/Math.abs(cc)
      x=(canvas.width/2)+Math.cos(arrow.angle)*arrow_dis
      y=(canvas.height/2)+Math.sin(arrow.angle)*arrow_dis
      point = calcPoint(x,y,@angle,2,size)
      side1 = calcPoint(x,y,@angle,1.5,size)
      side2 = calcPoint(x,y,@angle,0.5,size)
      context.fillStyle = 'rgba(255,255,255,'+arrow.opacity+')'
      context.beginPath()
      context.moveTo(point.x,point.y)
      context.lineTo(side1.x,side1.y)
      context.lineTo(side2.x,side2.y)
      context.closePath()
      context.fill()

  calcPoint:(x,y,angle,am,len)=>
    {x:x+Math.cos(angle+Math.PI*am)*len,y:y+Math.sin(angle+Math.PI*am)*len}
