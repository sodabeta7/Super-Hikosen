class BulletPool
  constructor:(@size)->
    @free_pool=[]
    @used_pool=[]
    for i in [1..@size]      
      @free_pool.push(new Bullet(0,0))
    return

  get:(x,y,angle)=>
    if @free_pool? and @free_pool.length>0
      @free_pool[0].set(x,y,angle)
      @used_pool.push(@free_pool.shift())

  draw:(cxt,bounds)=>
    i=@used_pool.length
    while i--
      if @used_pool[i].draw(cxt,bounds)
        @used_pool[i].reset()
        @free_pool.push((@used_pool.splice(i,1))[0])

  init:(data)=>    
    d_bp=data
    bp=this
    bp.free_pool=new Array()
    bp.used_pool=new Array()
    for b,i in d_bp.free_pool
      bp.free_pool[i]=new Bullet()
      cp_attr(bp.free_pool[i],d_bp.free_pool[i])
    for b,i in d_bp.used_pool
      bp.used_pool[i]=new Bullet()
      cp_attr(bp.used_pool[i],d_bp.used_pool[i])