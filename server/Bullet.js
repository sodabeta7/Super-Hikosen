var Bullet,exports,bind=function(fn,me){return function(){return fn.apply(me,arguments)}};Bullet=function(){function Bullet(x1,y1){this.x=x1;this.y=y1;this.prt=bind(this.prt,this);this.reset=bind(this.reset,this);this.update=bind(this.update,this);this.set=bind(this.set,this);this.speed=0;this.angle=0}Bullet.prototype.set=function(x,y,angle,speed){this.x=x;this.y=y;this.speed=speed!=null?speed:6;return this.angle=angle!=null?angle:0};Bullet.prototype.update=function(){this.y+=this.speed*Math.sin(this.angle);return this.x+=this.speed*Math.cos(this.angle)};Bullet.prototype.reset=function(){return this.x=this.y=this.speed=0};Bullet.prototype.prt=function(){return console.log(this.x+" "+this.y)};return Bullet}();module.exports=exports=Bullet;