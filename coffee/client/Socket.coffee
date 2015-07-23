###
  Socket communication between brower and server
###
init_socket=(socket,scene)->
  socket.in_connection=false
  socket.game_scene=scene  

  update_scene_single_user=(data)=>
    ###
      update a single user's state in game scene
    ###
    scene.users[data.id]=new Player(data.id)
    # for key,d of data      
    #   if key is 'bullet_pool'
    #     scene.users[data.id][key]=new BulletPool(50)
    #     for kk,dd of d                    
    #       scene.users[data.id][key][kk]=dd
    #       if kk is 'free_pool' or kk is 'used_pool'

    #   else
    #     scene.users[data.id][key]=d      
    u=scene.users[data.id]
    cp_attr(u,data)
    u['bullet_pool']=new BulletPool(50)
    cp_attr(u['bullet_pool'],data['bullet_pool'])
    bp=u['bullet_pool']
    d_bp=data['bullet_pool']
    bp.free_pool=new Array()
    bp.used_pool=new Array()
    for b,i in d_bp.free_pool
      bp.free_pool[i]=new Bullet()
      cp_attr(bp.free_pool[i],d_bp.free_pool[i])
    for b,i in d_bp.used_pool
      bp.used_pool[i]=new Bullet()
      cp_attr(bp.used_pool[i],d_bp.used_pool[i])
    return

  update_scene_users=(data)=>
    ###
      update all users' states in game scene
    ###
    scene.users={}
    for uid,u of data
      update_scene_single_user(u)      
    scene.user=scene.users[scene.user.id]  

  socket.on('welcome',((user_data)->
    ###
      Actions for the acknowledged message from server
    ###
    socket.in_connection=true
    scene.user=new Player(user_data.id)
    scene.user.name=user_data.name
    scene.users[user_data]=scene.user
    delete scene.users[-1]
    socket.emit('validate',scene.user)    
  ))

  socket.on('test',((data)->
    ###
      For debug
    ###
    console.log('test: '+data)
  ))

  socket.on('player_join',((data)->
    ###
      Actions for new player joining the game
    ###
    update_scene_users(data)
    console.log('number of other users '+olen(scene.users))
  ))

  socket.on('player_leave',((data)->
    ###
      Actions for player leaving the game
    ###
    update_scene_users(data)
    console.log('number of other users '+olen(scene.users))
  ))

  # socket.on('update_users',((user_data)->    
  #   # console.log(user_data.id+" "+user_data.x+" "+user_data.y)
  #   update_scene_single_user(user_data)
  # ))

  socket.on('sync_enemies',((enemies_data)->
    ###
      Syncronize the data with server
    ###
    es=scene.enemies=[]    
    for e_data in enemies_data
      e=new Enemy(e_data)
      es.push(e)
    return
  ))

  socket.on('update_users',((data)->    
    ###
      Update players' score and health data
    ###
    user=data[0]
    users=data[1]    
    scene.user.score=user.score
    scene.user.health=user.health
    scene.users={}
    for uid,u of users
      if uid!=user.id
        update_scene_single_user(u)
    scene.users[user.id]=scene.user
  ))

  socket.on('death',((data)->
    ###
      Actions for the user losing the game
    ###
    # alert('you lose');
    console.log('you lose');
    scene.game_state=1
    swal({
      title: "You Are Dead"
      text: "Go to see rank or back to game"
      type: "warning"
      showCancelButton: true
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "Rank"
      cancelButtonText: "Game"
      closeOnConfirm: false
      closeOnCancel: false
    },
    ((isConfirm)->
      if isConfirm #see history
        window.location.href="/rank"
      else #back to game
        swal("Again!", "Let's start the game", "success")
        socket.emit('restart_game',null)
        scene.game_state=0
      return false
    ))
  ))
  # socket.on('update',((data)->
  #   newpalyer=false
  #   scene=socket.game_scene
  #   if !scene.users[data.id]
  #     newpalyer=true
  #     scene.users[data.id]=new Player(data.id)
  #     scene.arrows[data.id]=new Arrow(scene.users[data.id],scene.camera)
  #   player=scene.users[data.id]
  #   player.name=data.name
  #   return if player.id==scene.user.id    
  #   if newpalyer
  #     player.x=data.x
  #     player.y=data.y
  #   else
  #     player.target_x=data.x
  #     player.target_y=data.y
  #   player.angle=data.angle
  #   player.momentum=data.momentum    
  # ))
  # socket.on('userclose',((data)->
  #   if socket.game_scene.users[data.id]
  #     delete socket.game_scene[data.id]
  #     delete socket.arrows[data.id]
  # ))
  socket.on('disconnect',(()->
    socket.in_connection=false
  ))

