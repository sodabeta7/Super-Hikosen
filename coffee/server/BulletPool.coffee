Bullet=require('./Bullet')
Max_Dis=Math.sqrt(1396*1396+678*678)
class BulletPool
  constructor:(@size)->
    @free_pool=[]
    @used_pool=[]    
    for i in [1..@size]      
      @free_pool.push(new Bullet(0,0))

  get:(x,y,angle)=>
    if @free_pool? and @free_pool.length>0
      @free_pool[0].set(x,y,angle)
      @used_pool.push(@free_pool.shift())

  update:(ship_x,ship_y)=>
    # debugger
    # @get(x,y,angle)
    i=@used_pool.length
    # console.log('update used '+@used_pool.length)
    while i--
      @used_pool[i].update()
      # console.log(@gdis(@used_pool[i],ship_x,ship_y))
      if @gdis(@used_pool[i],ship_x,ship_y)>=Max_Dis
        @used_pool[i].reset()
        @free_pool.push((@used_pool.splice(i,1))[0])

  gdis:(b,ship_x,ship_y)=>
    Math.sqrt(Math.pow(b.x-ship_x,2)+Math.pow(b.y-ship_y,2))

  prt:()=>
    p=console.log
    p('free : '+@free_pool.length + ' '+ 'used : '+@used_pool.length)
    for b in @used_pool
      b.prt()      
      break

module.exports=exports=BulletPool