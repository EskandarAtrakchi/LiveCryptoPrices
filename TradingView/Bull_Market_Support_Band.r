// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © zkdev

//@version=5
indicator('Bull Market Support Band', overlay=true, timeframe='W', timeframe_gaps=true)

source = close
smaLength = 20
emaLength = 21

sma = ta.sma(source, smaLength)
ema = ta.ema(source, emaLength)

outSma = request.security(syminfo.tickerid, timeframe.period, sma)
outEma = request.security(syminfo.tickerid, timeframe.period, ema)

smaPlot = plot(outSma, color=color.new(color.red, 0), title='20w SMA')
emaPlot = plot(outEma, color=color.new(color.green, 0), title='21w EMA')

fill(smaPlot, emaPlot, color=color.new(color.orange, 75), fillgaps=true)
