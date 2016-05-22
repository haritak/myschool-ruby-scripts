require 'rsruby'
r = RSRuby.instance

r.tiff('output.tiff')
r.jpeg('output.jpeg')
n = r.runif(1000)
n.map! { |e|
  r.floor(e*10)
}
puts n
t = r.table(n)
r.barplot(t)

gets

r.dev_off(2)
r.dev_off(3)
r.dev_off(4)
gets

