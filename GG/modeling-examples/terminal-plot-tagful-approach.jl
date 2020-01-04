"""
```bnf
action  : @forward <Julia Float64>
        | @turn <Julia Float64>

actions : <action>
        | <actions> <action>

start   : actions <EOF>
```
"""
module TagfulExample
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

## Types of Modeling 
abstract type Statement end

struct Forward <: Statement
    distance :: Float64
end

struct Turn <: Statement
    angle :: Float64
end

## Interpretation of Modeling
function interpret_statement(pen::Pen, s::Turn)
    pen.angle += s.angle
end

function interpret_statement(pen::Pen, s::Forward)
    dist = s.distance
    x, y = pen.x, pen.y
    Δy, Δx = sincos(pen.angle) .* dist
    lines!(pen.canvas, x, y, x + Δx, y + Δy)
    pen.x = x + Δx
    pen.y = y + Δy
    nothing
end

## Interpretater
interpret_dsl(pen::Pen, stmts::AbstractArray{Statement}) =
    for each in Statement
        interpret_statement(pen, each)
    end
end

end # module