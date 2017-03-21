inlets = 1
outlets = 1

var u //float 0.<u<1. that chooses a point between the first and last point
var x = []
var y = []
var n
var sumy
var sumx


function list()
{
  if(arguments.length==2)
  {
    newLength = x.push(arguments[0])
    newLength = y.push(arguments[1])
    n = x.length-1
  }
}


function factorial(a)
{
  if(a==0)
  {
    return 1
  }
    return a*factorial(a-1)
}


function msg_float(u)
{ 
  if(0<=u && 1>=u)
  {
    sumy = 0
    sumx = 0
    for(k=0; k<=n; k++)
    {
      blend = (factorial(n)/(factorial(k)*(factorial(n-k))))*(Math.pow(u, k))*(Math.pow(1-u, n-k))
      sumy += (y[k])*blend
      sumx += (x[k])*blend 
    }
    outlet(0,[sumx, sumy])
  }
}


function anything()
{
  if(messagename=="clear")
  {
    x = []
    y = []
  }
}