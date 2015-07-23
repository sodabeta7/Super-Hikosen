express=require('express')
app=express()
path=require('path')
server=require('http').Server(app)
io=require('socket.io')(server)
BulletPool=require('./BulletPool')
Enemy=require('./Enemy')
bodyParser=require('body-parser')
cookieParser=require('cookie-parser')
session=require('express-session')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
hash=require('./pass').hash
app.set('view engine','ejs')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
app.set('views', __dirname+'/views')

app.use(bodyParser.urlencoded({extended:false}))
app.use(session({
  resave:false
  saveUninitialized:false
  secret:'topsecret'
}))

app.use(((req, res, next)->
  err=req.session.error
  msg=req.session.success
  delete req.session.error
  delete req.session.success
  res.locals.message=''
  res.locals.message='<p class="msg error">'+err+'</p>' if err
  res.locals.message='<p class="msg success">'+msg+'</p>' if msg
  next()
))

users={
  tj:{name:'tj'}
}
hash('foobar',((err, salt, hash)->
  if err
    throw err
  users.tj.salt=salt
  users.tj.hash=hash
  users.tj.score=10
))
authenticate=(name, pass, fn)->
  if not module.parent
    console.log('authenticating %s:%s', name, pass)
  user=users[name]  
  if not user
    return fn(new Error('cannot find user'))  
  hash(pass,user.salt, ((err, hash)->
    if err
      return fn(err)
    if hash == user.hash
      return fn(null, user)
    fn(new Error('invalid password'))
  ))

restrict=(req, res, next)->
  if req.session.user
    next()
  else
    req.session.error='Access denied!'
    res.redirect('/login')
  
app.get('/',((req, res)->
  res.redirect('/login')
))
app.get('/index',restrict,((req, res)->
  res.render('index')
))

app.get('/logout', ((req, res)->
  req.session.destroy((()->
    res.redirect('/')
  ))
))
app.get('/login', ((req, res)->
  res.render('login')
))
gb_uname=null
app.post('/login',((req,res)->  
  if req.body.type=="Sign In"
    authenticate(req.body.username,req.body.password,((err,user)->
      if user
        req.session.regenerate((()->
          req.session.user=user
          req.session.success='Authenticated as '+user.name+' click to <a href="/logout">logout</a>.'
          gb_uname=user.name
          res.redirect('./index')
        ))
      else
        # req.session.error='Authentication failed, please check your '+' username and password.'
        # res.redirect('/login')
        uname=req.body.username
        if uname in users
          req.session.error='User already exists '
          res.redirect('/index')    
        else
          console.log('REGISTER')
          hash(req.body.password, ((err, salt, hash)->
            if err
              throw err
            users[req.body.username]={
              name: req.body.username
              salt: salt
              hash: hash
              score: 10
            }
          ))
          gb_uname=req.body.username
          req.session.success='Registered as '+req.body.username
          res.redirect('/index')    
    ))
  else 
    uname=req.body.username
    if uname in users
      req.session.error='User already exists '
      res.redirect('/login')    
    else
      hash(req.body.password, ((err, salt, hash)->
        if err
          throw err
        users[req.body.username]={
          name: req.body.username
          salt: salt
          hash: hash
          score: 10
        }
      ))
      gb_uname=req.body.username
      req.session.success='Registered as '+req.body.username
      res.redirect('/login')    
))

prt=console.log
sockets={}
online_players={}
enemies=[]
config=
  Enemy_Per_Player:3
  Max_Enemies:2
  SCORE_PER_HIT:1
  HEALTH_PER_HIT:0.05

app.use(express.static(path.resolve(__dirname + '/../client')))
app.use('/scripts',express.static(path.resolve(__dirname+'/../node_modules/')))
console.log(path.resolve(__dirname+'/../node_modules/'))
# io.on('connection',(socket)=>
#   prt('a user connected')
#   user_id=socket.id
#   socket.emit('confirm',user_id)
#   socket.on('valid_confirm',(player)=>
#     player.id=user_id
#     sockets[player.id]=socket
#     online_players.push(player)
#     io.emit('player_list',online_players)    
#   )
# )

gdis=(x1,y1,x2,y2)->
  Math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2))

grand=(min, max)->
  Math.random()*(max-min)+min

find_nearest_user=(e)->
  mind=1e200
  rp=null
  for id,p of online_players
    dis=gdis(e.x,e.y,p.x,p.y)
    if dis<mind
      mind=dis
      rp=p
  rp

enemy_update_beh=(e)->
  u=find_nearest_user(e)
  mouse=
    x:e.x
    y:e.y
    tar:false
  if u?
    mouse.x=u.x
    mouse.y=u.y
    mouse.tar=true
    mouse.tid=u.id
    # e.momentum=e.target_momentum=e.max_momentum
    # e.momentum=e.target_momentum=grand(e.momentum-grand(0,e.momentum/4),e.max_momentum)
    # e.momentum=e.target_momentum=grand(0,e.max_momentum)
    e.userUpdate(mouse.x,mouse.y)
  mouse

add_enemy=(user)->
  return if enemies.length>=config.Max_Enemies    
  e=new Enemy(user)
  console.log("momentum "+e.momentum)
  enemies.push(e)   

rand_data=[]
player_max_score={}

calc_rank=()->
  res=[]
  for uname,score of player_max_score
    res.push({name:uname,score:score})
  res.sort(((a,b)=>
    return a.score-b.score
  ))
  return res
app.get('/rank',restrict,((req, res)->
  res.render('rank',{
    # ranklist:[{name:'Alice',score:1100},{name:'Bob',score:900},{name:'Ene',score:768},{name:'Baka',score:432}]
    ranklist:calc_rank()
  })
))

io.on('connection',((socket)->
  console.log('new user')
  user={}
  user.id=socket.id
  user.name=gb_uname
  socket.emit('welcome',user)
  socket.on('validate',((user_data)->  
    user=user_data
    sockets[user.id]=socket
    online_players[user.id]=user_data
    prt('validate user ' + user.id)    
    if user.x? then prt('x '+user.x) else prt ('x undefined')
    if user.y? then prt('y '+user.y) else prt ('y undefined')
    prt Object.keys(online_players).length
    prt(p.id) for pid,p of online_players    
    io.emit('player_join',online_players)
    for i in [1..config.Enemy_Per_Player]
      add_enemy(user)
    return
  ))
  socket.on('disconnect',(()->
    prt "user "+user.id+" leave"
    delete online_players[user.id]
    prt Object.keys(online_players).length
    socket.broadcast.emit('player_leave',online_players)
  ))
  socket.on('restart_game',(()->
    socket.emit('welcome',user)
  ))
  #chekc a's bullet if hit user b
  # gao_bullet_hit=(a,b)=>
  #   for bl in a.bullet_pool.used_pool
  #     if check_bullet_hit(bl,b)
  #       b.health-=Damage_Per_Bullet
  #       a.score+=Score_Per_Hit
  #       if b.health<=0
  #         return gao_dead()

  # gao_collision=()=>
  #   cur_user=online_players[user.id]
  #   for uid,u of online_players
  #     gao_bullet_hit(u,cur_user)

  add_user_score=(usr)=>
    usr.score+=config.SCORE_PER_HIT if usr.score?

  sub_user_health=(usr)=>
    usr.health-=config.HEALTH_PER_HIT if usr.health?

  vec_trans=(angle,x,y)=>  
    p=
      x:x*Math.cos(angle)-y*Math.sin(angle)
      y:x*Math.sin(angle)+y*Math.cos(angle)
    p

  crs=(x1,y1,x2,y2)=>    
    y1=-y1
    y2=-y2
    # console.log(x1+" "+y1+" "+x2+" "+y2)
    x1*y2-x2*y1

  check_bullet_hit=(bullet,player)=>
    x1=player.x
    y1=player.y
    x2=x1+player.width
    y2=y1
    x3=x2
    y3=y2+player.height
    x4=x1
    y4=y3
    angle=player.angle-Math.PI/2
    vec=vec_trans(angle,x2-x1,y2-y1)
    # console.log("vec "+vec.x+" "+vec.y)
    x2=x1+vec.x
    y2=y1+vec.y
    vec=vec_trans(angle,x3-x1,y3-y1)
    x3=x1+vec.x
    y3=y1+vec.y
    vec=vec_trans(angle,x4-x1,y4-y1)
    x4=x1+vec.x
    y4=y1+vec.y
    x=bullet.x
    y=bullet.y  
    return crs(x-x4,y-y4,x1-x4,y1-y4)>=0 and crs(x-x1,y-y1,x2-x1,y2-y1)>=0 and
    crs(x-x2,y-y2,x3-x2,y3-y2)>=0 and crs(x-x3,y-y3,x4-x3,y4-y3)>=0
    # pr=console.log
    # pr(x1+" "+y1)
    # pr(x2+" "+y2)
    # pr(x3+" "+y3)
    # pr(x4+" "+y4)

  process_bullet_hit=(ua,ub)=>
    for b_bullet in ub.bullet_pool.used_pool
      if check_bullet_hit(b_bullet,ua)
        # console.log('here')
        # console.log(''+ua.id+' '+ua.health)
        add_user_score(ub)
        sub_user_health(ua)
        # console.log(''+ua.id+' '+ua.health)

    for a_bullet in ua.bullet_pool.used_pool
      if check_bullet_hit(a_bullet,ub)
        console.log('there')
        add_user_score(ua)
        sub_user_health(ub)

  process_hit=(cur_user)=>
    for uid,u of online_players
      if uid!=cur_user.id
        process_bullet_hit(cur_user,u)

    for enemy in enemies
      process_bullet_hit(cur_user,enemy)

  update_death_users=()=>
    dead_usrs=[]
    for uid,u of online_players
      if u.health<=0
        console.log('dead '+uid)
        sockets[uid].emit('death',u)
        dead_usrs.push(uid)
    for uid in dead_usrs
      delete online_players[uid]

  update_death_enemies=()=>
    dead_enemies=[]
    for e,i in enemies
      if e.health<=0
        dead_enemies.push(i)
    for eid in dead_enemies
      enemies.split(eid,1)

  socket.on('update',((user_data)->
    # return
    # prt(user_data.id+" "+user_data.x+" "+user_data.y)
    # console.log('before user '+user_data.id+" "+user_data.health)
    online_players[user_data.id]=user_data
    return
    process_hit(user_data)
    update_death_users()
    update_death_enemies()
    user_data=online_players[user_data.id]      
    # console.log('after user '+user_data.id+" "+user_data.health+'\n')
    for uid,u of online_players
      sockets[uid].emit('update_users',[online_players[uid],online_players])
    return
  ))
)
)

e_upd_cnt=0
e_shoot_cnt=0
setInterval((()->  
  return if enemies.length==0
  for e,i in enemies
    mouse=enemy_update_beh(e)
    if e_shoot_cnt==0
      e.shoot(e.x,e.y,e.angle)
    e_shoot_cnt=(e_shoot_cnt+1)%5
    for oe,j in enemies
      if j!=i
        # console.log(gdis(e.x,e.y,oe.x,oe.y))
        mouse.x+=1000/gdis(e.x,e.y,oe.x,oe.y)
        mouse.y+=1000/gdis(e.x,e.y,oe.x,oe.y)
    # console.log("mouse "+mouse.x+" "+mouse.y+" "+e.momentum+" "+e.x+" "+e.y)
    # e.userUpdate(mouse.x,mouse.y) 
    e.update(mouse)
    # e.bullet_pool.prt()  
  io.emit('sync_enemies',enemies)  
  return
),1000/60)


add_user_score=(usr)=>
  usr.score+=config.SCORE_PER_HIT if usr.score?

sub_user_health=(usr)=>
  usr.health-=config.HEALTH_PER_HIT if usr.health?

vec_trans=(angle,x,y)=>  
  p=
    x:x*Math.cos(angle)-y*Math.sin(angle)
    y:x*Math.sin(angle)+y*Math.cos(angle)
  p

crs=(x1,y1,x2,y2)=>    
  y1=-y1
  y2=-y2
  # console.log(x1+" "+y1+" "+x2+" "+y2)
  x1*y2-x2*y1

check_bullet_hit=(bullet,player)=>
  x1=player.x
  y1=player.y
  x2=x1+player.width
  y2=y1
  x3=x2
  y3=y2+player.height
  x4=x1
  y4=y3
  angle=player.angle-Math.PI/2
  vec=vec_trans(angle,x2-x1,y2-y1)
  # console.log("vec "+vec.x+" "+vec.y)
  x2=x1+vec.x
  y2=y1+vec.y
  vec=vec_trans(angle,x3-x1,y3-y1)
  x3=x1+vec.x
  y3=y1+vec.y
  vec=vec_trans(angle,x4-x1,y4-y1)
  x4=x1+vec.x
  y4=y1+vec.y
  x=bullet.x
  y=bullet.y  
  return crs(x-x4,y-y4,x1-x4,y1-y4)>=0 and crs(x-x1,y-y1,x2-x1,y2-y1)>=0 and
  crs(x-x2,y-y2,x3-x2,y3-y2)>=0 and crs(x-x3,y-y3,x4-x3,y4-y3)>=0
  # pr=console.log
  # pr(x1+" "+y1)
  # pr(x2+" "+y2)
  # pr(x3+" "+y3)
  # pr(x4+" "+y4)

process_bullet_hit=(ua,ub)=>
  for b_bullet in ub.bullet_pool.used_pool
    if check_bullet_hit(b_bullet,ua)
      # console.log('here')
      # console.log(''+ua.id+' '+ua.health)
      add_user_score(ub)
      sub_user_health(ua)
      # console.log(''+ua.id+' '+ua.health)

  for a_bullet in ua.bullet_pool.used_pool
    if check_bullet_hit(a_bullet,ub)
      console.log('there '+ub.health)
      add_user_score(ua)
      sub_user_health(ub)
      console.log('after there '+ub.health+'\n')

process_hit=(cur_user)=>
  for uid,u of online_players
    if uid!=cur_user.id
      process_bullet_hit(cur_user,u)

  for enemy in enemies
    process_bullet_hit(cur_user,enemy)

update_death_users=()=>
  dead_usrs=[]
  for uid,u of online_players
    if u.health<=0
      console.log('dead '+uid)
      sockets[uid].emit('death',u)
      if uid in player_max_score
        player_max_score[u.name]=Math.max(player_max_score[uid],u.score)
      else
        player_max_score[u.name]=u.score
      dead_usrs.push(uid)
  for uid in dead_usrs
    delete online_players[uid]

update_death_enemies=()=>
  dead_enemies=[]
  for e,i in enemies
    if e.health<=0
      dead_enemies.push(i)
  for eid in dead_enemies
    enemies.split(eid,1)

setInterval((()->
  for uid,u of online_players
    user_data=u
    process_hit(user_data)
    update_death_users()
    update_death_enemies()
    user_data=online_players[user_data.id]      
    # console.log('after user '+user_data.id+" "+user_data.health+'\n')
  for uid,u of online_players
    sockets[uid].emit('update_users',[online_players[uid],online_players])
  return
),1000/60
)
server.listen(3000)