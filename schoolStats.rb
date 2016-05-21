require 'rsruby'
r = RSRuby.instance
#Call R functions on the r object
data = r.rnorm(100)
r.plot(data)
 gets
#Call with named args
r.plot({'x' => data, 'y' => data, 'xlab' => 'test', 'ylab' => 'test'})
 gets

