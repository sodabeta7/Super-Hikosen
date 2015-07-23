class A
  @x:
    x:1
    y:2
  constructor:()->
    @x=A.x.x
    @y=1

a=new A()
console.log(a.y)
console.log(a.x)
