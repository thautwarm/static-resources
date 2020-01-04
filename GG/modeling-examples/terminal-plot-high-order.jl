"""
```bnf
action  : @forward <Julia Float64>
        | @turn <Julia Float64>
        | @when <Julia Function> => begin <actions> end

actions : <action>
        | <actions> <action>

start   : actions <EOF>
```
"""
module TagfulHighOrder
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

struct When <: Statement
    predicate::Function
    actions :: Vector{Statement}
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

function interpret_statement(pen::Pen, s::When)
    if s.predicate(pen)
        interpret_dsl(pen, s.actions)
    end
end

## Interpreter
function interpret_dsl(pen::Pen, stmts::AbstractArray{Statement})
    for each in stmts
        interpret_statement(pen, each)
    end
end

end