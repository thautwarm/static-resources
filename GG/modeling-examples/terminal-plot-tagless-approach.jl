"""
```bnf
action  : @forward <Julia Float64>
        | @turn <Julia Float64>

actions : <action>
        | <actions> <action>

start   : actions <EOF>
```
"""
module TaglessExample
using MLStyle
using UnicodePlots

mutable struct Pen
    x          :: Float64
    y          :: Float64
    angle      :: Float64
    canvas     :: Canvas
end

Base.show(io::IO, p::Pen) = Base.print(io, "Pen", (p.x, p.y, p.angle))

function Pen(window::Tuple{Int, Int} = (60, 15);
             loc::Tuple{Float64, Float64} = (0.5, 0.5),
             angle::Float64 = 0.)
    x, y = loc
    width, height = window
    canvas = BrailleCanvas(width, height, origin_x = x, origin_y = y, width = 1., height = 1.)
    Pen(x, y, angle, canvas)
end

function forward(pen::Pen, dist::Float64) 
    x, y = pen.x, pen.y
    Δy, Δx = sincos(pen.angle) .* dist
    lines!(pen.canvas, x, y, x + Δx, y + Δy)
    pen.x = x + Δx
    pen.y = y + Δy
    nothing
end

function turn(pen::Pen, theta::Float64)
    pen.angle += theta
end

end # module