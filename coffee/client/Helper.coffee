olen=(o)->
  Object.keys(o).length

drawRotatedImage=(cxt,image,x,y,angle)->
  cxt.save()
  cxt.translate(x,y)
  cxt.rotate(angle)
  cxt.drawImage(image,-image.width/2,-image.height/2)
  cxt.restore()

cp_attr=(a,b)->
  for key,d of b
    a[key]=d
  return