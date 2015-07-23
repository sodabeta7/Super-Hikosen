class Enemy
  constructor:(data)->
    for key,d of data
      this[key]=d    
    @bullet_pool=new BulletPool(100)
    @bullet_pool.init(data.bullet_pool)
    @width=image_repo.enemy_ship.width
    @height=image_repo.enemy_ship.height

  draw:(cxt,bounds,b_cxt)=>              
    # cxt.fillStyle='rgba(226,219,226,'+opacity+')';
    cxt.shadowOffsetX=0
    cxt.shadowOffsetY=0
    drawRotatedImage(cxt,image_repo.enemy_ship,@x+@width/2,@y+@height/2,@angle+Math.PI/2)
    cxt.shadowBlur=0
    cxt.shadowColor=''
    @bullet_pool.draw(b_cxt,bounds)




