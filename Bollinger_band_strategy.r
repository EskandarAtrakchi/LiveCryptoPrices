//@version=5
// Bollinger Bands: Madrid : 14/SEP/2014 11:07 : 2.0
// This displays the traditional Bollinger Bands, the difference is 
// that the 1st and 2nd StdDev are outlined with two colors and two
// different levels, one for each Standard Deviation

strategy(shorttitle="MBB", title="Bollinger Bands", overlay=true)
src = input(close)
length = input.int(34, minval=1)
mult = input.float(2.0, minval=0.001, maxval=50)

basis = ta.sma(src, length)
dev = ta.stdev(src, length)
dev2 = mult*dev

upper1 = basis + dev
lower1 = basis - dev
upper2 = basis + dev2
lower2 = basis - dev2

colorBasis = src >= basis ? color.blue : color.orange

pBasis = plot(basis, linewidth=2, color=colorBasis)
pUpper1 = plot(upper1, color =  color.new(color.blue, 0), style =  plot.style_circles)
pUpper2 = plot(upper2, color= color.new(color.blue, 0))
pLower1 = plot(lower1, color = color.new(color.orange, 0), style =  plot.style_circles)
pLower2 = plot(lower2, color = color.new(color.orange, 0))

fill(pBasis,pUpper2, color = color.new(color.blue, 80))
fill(pUpper1, pUpper2, color = color.new(color.blue, 80))
fill(pBasis,pLower2, color = color.new(color.orange, 80))
fill(pLower1, pLower2, color = color.new(color.orange, 80))

if(close > upper2)
    strategy.entry("Long", strategy.long)
if(close < lower2)
    strategy.entry("Short", strategy.short)
if(close <= lower2)
    strategy.close("Long")
if(close >= upper2)
    strategy.close("Short")