var cp_attr,drawRotatedImage,olen;olen=function(o){return Object.keys(o).length};drawRotatedImage=function(cxt,image,x,y,angle){cxt.save();cxt.translate(x,y);cxt.rotate(angle);cxt.drawImage(image,-image.width/2,-image.height/2);return cxt.restore()};cp_attr=function(a,b){var d,key;for(key in b){d=b[key];a[key]=d}};