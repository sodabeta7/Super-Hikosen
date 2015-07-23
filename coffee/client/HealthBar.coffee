class HealthBar
  constructor:(@sx,@sy)->
    @width=300
    @hue=0    

  reset:(ctx,bgcolor)=>    
    ctx.fillStyle='hsl('+bgcolor+',50%,10%)'
    # ctx.fillStyle=@bgcolor;
    ctx.fillRect(@sx,@sy,300,25);

  draw:(ctx,health,bgcolor)=>
    @reset(ctx,bgcolor)
    @hue=(health/100.0)*126
    @width=(health/100.0)*300
    ctx.fillStyle='hsla('+@hue+', 100%, 40%, 1)';
    ctx.fillRect(@sx,@sy,@width,25);
    grad=ctx.createLinearGradient(0,0,0,130);
    grad.addColorStop(0,"transparent");
    grad.addColorStop(1,"rgba(0,0,0,0.5)");
    ctx.fillStyle=grad;
    ctx.fillRect(@sx,@sy,@width,25);