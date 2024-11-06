//@version=5
indicator("Activity and Volume Orderflow Profile [AlgoAlpha]", "AlgoAlpha - 👽Activity and Volume",overlay = true, max_boxes_count = 500)

ptype = input.string("Comparison", "Profile Type", ["Comparison", "Net Order Flow"])
plook = input.int(70, "Profile Lookback")
res = input.int(20, "Profile Resolution")
scale = input.int(30, "Profile Horizontal Scale")
off = input.int(7, "Profile Horizontal Offset")
h = input.bool(true, "Show Profile", group = "Appearance")
b = input.bool(true, "Show VIsualisation of Lookback Period", group = "Appearance")
hm = input.bool(true, "Show Heatmap", group = "Appearance")
mint = input.int(10, "Minimum Transaprency", tooltip = "Adjust this to make the heatmap highlight only areas of high activity (0-100)", minval = 0, maxval = 100, group = "Appearance")
green = input.color(#00ffbb, "Up Color", group = "Appearance")
red = input.color(#ff1100, "Down Color", group = "Appearance")
yel = chart.fg_color

var poc = 0.0
var left = 0
var boxes = array.new_box()
var lines = array.new_line()
var t = array.new_box() //Lookback Data
top_boundaries = array.new_float(res)
top_boundaries1 = array.new_float(res)
bottom_boundaries = array.new_float(res)
bottom_boundaries1 = array.new_float(res)
binlen = array.new_float(res)
binlen1 = array.new_float(res)
highs = array.new_float()
lows = array.new_float()
buyVolumes = array.new_float()
sellVolumes = array.new_float()

for i = 0 to bar_index - (bar_index - plook)
    highs.push(high[i])
    lows.push(low[i])
    buyVolumes.push(close[i] > open[i] ? volume[i] : 0)
    sellVolumes.push(open[i] > close[i] ? volume[i] : 0)


maxx = array.max(highs)
minn = array.min(lows)
size = array.size(highs)

while boxes.size() > 0
    boxes.shift().delete()
while lines.size() > 0
    lines.shift().delete()

if size > 0
    step = (maxx - minn) / res
    granularity = res
    for i = 0 to granularity - 1
        bin_size = 0.0
        bottom = minn + (i*step)
        top = minn + ( (i+1)*step )
        bottom_boundaries.insert(i, bottom)
        top_boundaries.insert(i, top)   
        for j = 0 to array.size(highs) - 1
            candle_above_hbar = lows.get(j) > top
            candle_below_hbar = highs.get(j) < bottom
            is_candle_in_bucket = not (candle_above_hbar or candle_below_hbar)
            bin_size += is_candle_in_bucket ? buyVolumes.get(j) : 0
        array.insert(binlen, i, bin_size)

if size > 0
    step = (maxx - minn) / res
    granularity = res
    for i = 0 to granularity - 1
        bin_size = 0.0
        bottom = minn + (i*step)
        top = minn + ( (i+1)*step )
        bottom_boundaries1.insert(i, bottom)
        top_boundaries1.insert(i, top)   
        for j = 0 to array.size(highs) - 1
            candle_above_hbar = lows.get(j) > top
            candle_below_hbar = highs.get(j) < bottom
            is_candle_in_bucket = not (candle_above_hbar or candle_below_hbar)
            bin_size += is_candle_in_bucket ? sellVolumes.get(j) : 0
        array.insert(binlen1, i, bin_size)

if ptype == "Comparison"
    for i = 0 to res - 1
        box_right = bar_index + off + scale
        box_left = box_right - math.round(binlen.get(i))/math.round(binlen.max()) * scale
        box_top = array.get(top_boundaries, i)
        box_bottom = array.get(bottom_boundaries, i)
        boxes.push(h ? box.new(box_left, box_top, box_right, box_bottom, border_style = line.style_solid, border_color = binlen.max() == binlen.get(i) ? color.new(yel, 0) : color.new(green, 0), border_width = 1, bgcolor = binlen.max() == binlen.get(i) ? color.new(yel, 90) : color.new(green, 90), text = str.tostring(binlen.get(i), format.volume), text_color = chart.fg_color) : na)

    for i = 0 to res - 1
        box_left = bar_index + off + scale
        box_right = box_left + math.round(binlen1.get(i))/math.round(binlen1.max()) * scale
        box_top = array.get(top_boundaries1, i)
        box_bottom = array.get(bottom_boundaries1, i)
        boxes.push(h ? box.new(box_left, box_top, box_right, box_bottom, border_style = line.style_solid, border_color = binlen1.max() == binlen1.get(i) ? color.new(yel, 0) : color.new(red, 0), border_width = 1, bgcolor = binlen1.max() == binlen1.get(i) ? color.new(yel, 90) : color.new(red, 90), text = str.tostring(binlen1.get(i), format.volume), text_color = chart.fg_color) : na)

else if ptype == "Net Order Flow"
    for i = 0 to res - 1
        box_left = bar_index + off + scale
        box_right = box_left + (math.round(binlen1.get(i)-binlen.get(i))/math.max(math.round(binlen1.max()), math.round(binlen.max())) * scale)
        box_top = array.get(top_boundaries1, i)
        box_bottom = array.get(bottom_boundaries1, i)
        dircol = binlen1.get(i) > binlen.get(i) ? red : green
        boxes.push(h ? box.new(box_left, box_top, box_right, box_bottom, border_style = line.style_solid, border_color = binlen1.max() == binlen1.get(i) ? color.new(ptype == "Net Order Flow" ? dircol : yel, 0) : color.new(dircol, 0), border_width = 1, bgcolor = binlen1.max() == binlen1.get(i) ? color.new(ptype == "Net Order Flow" ? dircol : yel, 90) : color.new(dircol, 90), text = str.tostring(math.abs(binlen1.get(i) - binlen.get(i)), format.volume), text_color = chart.fg_color) : na)

while t.size() > 0
    t.shift().delete()
if b
    t.push(box.new(bar_index-plook, ta.highest(plook), bar_index, ta.lowest(plook), color.new(chart.fg_color, 40), 1, line.style_solid, extend.none, bgcolor = color.new(chart.fg_color, 90), text = "Lookback Data", text_size = size.tiny, text_color = chart.fg_color, text_halign =  text.align_center, text_valign = text.align_top))

    for i = 0 to res - 1
        box_left = bar_index-plook
        box_right = bar_index
        box_top = array.get(top_boundaries1, i)
        box_bottom = array.get(bottom_boundaries1, i)
        transp = (100 - math.avg(math.round(binlen1.get(i))/math.round(binlen1.max()), math.round(binlen.get(i))/math.round(binlen.max())) * 100) + mint
        boxes.push(hm ? box.new(box_left, box_top, box_right, box_bottom, border_style = line.style_solid, border_color = color.new(chart.fg_color, 100), border_width = 1, bgcolor = color.new(chart.fg_color, transp)) : na)
