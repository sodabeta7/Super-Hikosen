app=null
authWindow=null

gameLoop=()->
  ### Game Main Loop ###

  app.update()
  app.sync()
  app.draw()

animate=()->
  ### Improve animation ###
  requestAnimFrame(animate)
  gameLoop()

window.requestAnimFrame = (()->
  ### Improve performance ###
  window.requestAnimationFrame       ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame    ||
  window.oRequestAnimationFrame      ||
  window.msRequestAnimationFrame     ||
  (callback,element)->
    window.setTimeout(callback,1000/60)
)()

setListeners=(app)->
  ### Register all event listeners ###
  window.addEventListener('resize',app.resize,false)
  document.addEventListener('mousemove',  app.mousemove, false)
  document.addEventListener('mousedown',  app.mousedown, false)
  document.addEventListener('mouseup',    app.mouseup, false) 
  document.addEventListener('touchstart', app.touchstart, false)
  document.addEventListener('touchend',   app.touchend, false)
  document.addEventListener('touchcancel',app.touchend, false)
  document.addEventListener('touchmove',  app.touchmove, false)
  document.addEventListener('keydown',    app.keydown, false)
  document.addEventListener('keyup',      app.keyup, false)   
  document.body.onselectstart=()->false

initApp=()->
  ### Initialization staffs ###
  return if app isnt null
  app=new App(document.getElementById('canvas'),document.getElementById('bullet-canvas'))
  setListeners(app)
  # setInterval(gameLoop,30)
  animate()

initApp()
