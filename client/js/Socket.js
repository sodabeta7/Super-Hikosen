var init_socket;init_socket=function(socket,scene){var update_scene_single_user,update_scene_users;socket.in_connection=false;socket.game_scene=scene;update_scene_single_user=function(_this){return function(data){var b,bp,d_bp,i,j,k,len,len1,ref,ref1,u;scene.users[data.id]=new Player(data.id);u=scene.users[data.id];cp_attr(u,data);u["bullet_pool"]=new BulletPool(50);cp_attr(u["bullet_pool"],data["bullet_pool"]);bp=u["bullet_pool"];d_bp=data["bullet_pool"];bp.free_pool=new Array;bp.used_pool=new Array;ref=d_bp.free_pool;for(i=j=0,len=ref.length;j<len;i=++j){b=ref[i];bp.free_pool[i]=new Bullet;cp_attr(bp.free_pool[i],d_bp.free_pool[i])}ref1=d_bp.used_pool;for(i=k=0,len1=ref1.length;k<len1;i=++k){b=ref1[i];bp.used_pool[i]=new Bullet;cp_attr(bp.used_pool[i],d_bp.used_pool[i])}}}(this);update_scene_users=function(_this){return function(data){var u,uid;scene.users={};for(uid in data){u=data[uid];update_scene_single_user(u)}return scene.user=scene.users[scene.user.id]}}(this);socket.on("welcome",function(user_data){socket.in_connection=true;scene.user=new Player(user_data.id);scene.user.name=user_data.name;scene.users[user_data]=scene.user;delete scene.users[-1];return socket.emit("validate",scene.user)});socket.on("test",function(data){return console.log("test: "+data)});socket.on("player_join",function(data){update_scene_users(data);return console.log("number of other users "+olen(scene.users))});socket.on("player_leave",function(data){update_scene_users(data);return console.log("number of other users "+olen(scene.users))});socket.on("sync_enemies",function(enemies_data){var e,e_data,es,j,len;es=scene.enemies=[];for(j=0,len=enemies_data.length;j<len;j++){e_data=enemies_data[j];e=new Enemy(e_data);es.push(e)}});socket.on("update_users",function(data){var u,uid,user,users;user=data[0];users=data[1];scene.user.score=user.score;scene.user.health=user.health;scene.users={};for(uid in users){u=users[uid];if(uid!==user.id){update_scene_single_user(u)}}return scene.users[user.id]=scene.user});socket.on("death",function(data){console.log("you lose");scene.game_state=1;return swal({title:"You Are Dead",text:"Go to see rank or back to game",type:"warning",showCancelButton:true,confirmButtonColor:"#DD6B55",confirmButtonText:"Rank",cancelButtonText:"Game",closeOnConfirm:false,closeOnCancel:false},function(isConfirm){if(isConfirm){window.location.href="/rank"}else{swal("Again!","Let's start the game","success");socket.emit("restart_game",null);scene.game_state=0}return false})});return socket.on("disconnect",function(){return socket.in_connection=false})};