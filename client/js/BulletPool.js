var BulletPool,bind=function(fn,me){return function(){return fn.apply(me,arguments)}};BulletPool=function(){function BulletPool(size){var i,j,ref;this.size=size;this.init=bind(this.init,this);this.draw=bind(this.draw,this);this.get=bind(this.get,this);this.free_pool=[];this.used_pool=[];for(i=j=1,ref=this.size;1<=ref?j<=ref:j>=ref;i=1<=ref?++j:--j){this.free_pool.push(new Bullet(0,0))}return}BulletPool.prototype.get=function(x,y,angle){if(this.free_pool!=null&&this.free_pool.length>0){this.free_pool[0].set(x,y,angle);return this.used_pool.push(this.free_pool.shift())}};BulletPool.prototype.draw=function(cxt,bounds){var i,results;i=this.used_pool.length;results=[];while(i--){if(this.used_pool[i].draw(cxt,bounds)){this.used_pool[i].reset();results.push(this.free_pool.push(this.used_pool.splice(i,1)[0]))}else{results.push(void 0)}}return results};BulletPool.prototype.init=function(data){var b,bp,d_bp,i,j,k,len,len1,ref,ref1,results;d_bp=data;bp=this;bp.free_pool=new Array;bp.used_pool=new Array;ref=d_bp.free_pool;for(i=j=0,len=ref.length;j<len;i=++j){b=ref[i];bp.free_pool[i]=new Bullet;cp_attr(bp.free_pool[i],d_bp.free_pool[i])}ref1=d_bp.used_pool;results=[];for(i=k=0,len1=ref1.length;k<len1;i=++k){b=ref1[i];bp.used_pool[i]=new Bullet;results.push(cp_attr(bp.used_pool[i],d_bp.used_pool[i]))}return results};return BulletPool}();