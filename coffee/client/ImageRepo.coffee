class ImageRepo
  constructor:()->
    @bullet=width:2,height:7
    @user_ship=new Image()
    @user_ship.src='imgs/ship.png'
    @enemy_ship=new Image()
    @enemy_ship.src='imgs/enemy.png'

image_repo=new ImageRepo()