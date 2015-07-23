class Camera
  ###
    Camera of the scene
  ###
  constructor:(@canvas,@context,@x,@y)->
    ###
      Constructor
    ###
    @min_zoom=1.3
    @max_zoom=1.8
    @zoom=@min_zoom
    @bgcolor=Math.random()*360

  setupContext:()=>
    ###
      Set up the canvas context and draw styles
    ###
    trans_x=@canvas.width/2-@x*@zoom
    trans_y=@canvas.height/2-@y*@zoom      
    @context.setTransform(1,0,0,1,0,0)
    @context.fillStyle='hsl('+@bgcolor+',50%,10%)'
    @context.fillRect(0,0,@canvas.width,@canvas.height)    
    @context.translate(trans_x,trans_y)
    @context.scale(@zoom,@zoom)

  update:(scene)=>
    ###
      Update the camera state
    ###
    # @bgcolor+=0.08
    # @bgcolor=0 if @bgcolor>360
    t_zoom=(scene.camera.max_zoom+(scene.camera.min_zoom-scene.camera.max_zoom)*Math.min(scene.user.momentum,scene.user.max_momentum)/scene.user.max_momentum)
    scene.camera.zoom+=(t_zoom-scene.camera.zoom)/60
    delta={x:(scene.user.x-scene.camera.x)/30,y:(scene.user.y-scene.camera.y)/30}
    if Math.abs(delta.x) + Math.abs(delta.y)>0.1
      scene.camera.x+=delta.x
      scene.camera.y+=delta.y      
    for wp in scene.rocks
      wp.x-=(wp.z-1)*delta.x
      wp.y-=(wp.z-1)*delta.y
    return

  getBounds:()=>
    ###
      Calculate the visible bounds
    ###
    [{x:@x-@canvas.width / 2 / @zoom,y:@y-@canvas.height / 2 / @zoom},
     {x:@x+@canvas.width / 2 / @zoom,y:@y+@canvas.height / 2 / @zoom}
    ]

  getInnerBounds:()=>
    ###
      Calculate the visible bounds
    ###
    [{x:@x-@canvas.width / 2 / @max_zoom,y:@y-@canvas.height / 2 / @max_zoom},
     {x:@x+@canvas.width / 2 / @max_zoom,y:@y+@canvas.height / 2 / @max_zoom}
    ]    

  getOuterBounds:()=>
    ###
      Calculate the visible bounds
    ###
    [{x:@x-@canvas.width / 2 / @min_zoom,y:@y-@canvas.height / 2 / @min_zoom},
     {x:@x+@canvas.width / 2 / @min_zoom,y:@y+@canvas.height / 2 / @min_zoom}
    ]

  startUILayer:()=>
    @context.setTransform(1,0,0,1,0,0)
