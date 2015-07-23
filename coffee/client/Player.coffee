class Player
  ###
    Player related opetaions and attributes
  ###
  constructor:(@id)->
    ###
      Constructor
      Initialize attributes
    ###
    @name=null
    @x=Math.random()*300-150
    @y=Math.random()*300-150
    @size=5
    @width=image_repo.user_ship.width
    @height=image_repo.user_ship.height
    @name=null
    @health=100
    @score=0
    @level=0
    @hover=false
    @momentum=0
    @max_momentum=3
    # @angle=2*Math.PI
    @angle=0
    @target_x=0
    @target_y=0
    @target_momentum=0
    @time_since_last_avt=0
    @time_since_last_ser=0
    @changed=0
    @bullet_pool=new BulletPool(50)
    @shoot_cnt=0

  update:(mouse)=>
    ###
      Update player's state
    ###
    ++@time_since_last_ser
    # console.log('x is '+@x+' y is '+@y+'momentum is '+@momentum)
    @x+=Math.cos(@angle)*@momentum
    @y+=Math.sin(@angle)*@momentum
    if @target_x!=0 or @target_y!=0
      @x+=(@target_x-@x)/20
      @y+=(@target_y-@y)/20
    if @gdis(@x,@y,mouse.worldx,mouse.worldy)<@size+2
      @hover=true
      mouse.player=this
    else
      @hover=false
    # console.log('x is '+@x+' y is '+@y)

  onclick:(mouse)=>
    ###
      Actions when clicked
    ###
    if mouse.which==1
      if mouse.ctrlKey and @hover
        console.log('on click!')
    else if mouse.which==2
      mouse.preventDefault()
      return true
    false

  userUpdate:(angle_tx,angle_ty)=>
    ###
      Update moving direction angle
    ###
    prestate=angle:@angle,momentum:@momentum
    angle_delta=Player.calAngle(@x,@y,angle_tx,angle_ty)-@angle
    angle_delta=Player.normalAngle(angle_delta)
    @angle+=angle_delta/5
    if @target_momentum!=@momentum
      @momentum+=(@target_momentum-@momentum)/20
    @momentum=Math.max(@momentum,0)
    @changed+=Math.abs(3*(prestate.angle-@angle))+@momentum
    if @changed>1
      @time_since_last_ser=0

  draw:(cxt,bounds,b_cxt)=>
    ###
      Draw player in the game scene
    ###
    opacity = Math.max(Math.min(20/Math.max(@time_since_last_ser-300,1),1),0.2).toFixed(3)
    if @hover
      cxt.fillStyle='rgba(192, 253, 247,'+opacity+')'
    else
      cxt.fillStyle='rgba(226,219,226,'+opacity+')';
    cxt.shadowOffsetX=0
    cxt.shadowOffsetY=0
    # cxt.shadowBlur=6
    # cxt.shadowColor='rgba(255, 255, 255, '+opacity*0.7+')'        
    # cxt.drawImage(image_repo.user_ship,@x,@y)
    drawRotatedImage(cxt,image_repo.user_ship,@x+@width/2,@y+@height/2,@angle+Math.PI/2)
    cxt.shadowBlur=0
    cxt.shadowColor=''    
    @drawName(cxt)
    @bullet_pool.draw(b_cxt,bounds)
  
  shoot:()=>    
    ###
      Shoot action
    ###
    @bullet_pool.get(@x,@y,@angle)

  drawName:(cxt)=>
    ###
      Draw player's name
    ###
    opacity=Math.max(Math.min(20/Math.max(@time_since_last_ser-300,1),1),0.2).toFixed(3)
    cxt.fillStyle='rgba(226,219,226,'+opacity+')'
    cxt.font=7+"px 'proxima-nova-1','proxima-nova-2', arial, sans-serif"
    cxt.textBaseline='hanging'
    width=cxt.measureText(@name).width
    cxt.fillText(@name,@x-width/2,@y+8)
    cxt.fillText(@score,@x-width/2,@y+16)

  @calAngle:(x1,y1,x2,y2)->
    ###
      Math calculation helper function
    ###
    Math.atan2(y2-y1,x2-x1)

  @normalAngle:(x)->
    ###
      Math calculation helper function
    ###
    while x<-Math.PI
      x+=2*Math.PI
    while x>Math.PI
      x-=2*Math.PI
    x

  gdis:(x1,y1,x2,y2)=>
    ###
      Math calculation helper function
    ###
    Math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2))




