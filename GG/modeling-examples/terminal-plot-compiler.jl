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
module TagfulCompiler
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

Code = Any

## Code Generator for DSL
function code_generator(pen::Code, s::Turn)
    :($pen.angle += $(s.angle))
end

function code_generator(pen::Code, s::Forward)
    quote
        dist = $(s.distance)
        x, y = $pen.x, $pen.y
        Δy, Δx = $sincos($pen.angle) .* dist
        $lines!($pen.canvas, x, y, x + Δx, y + Δy)
        $pen.x = x + Δx
        $pen.y = y + Δy
    end
end

function code_generator(pen::Code, s::When)
    codes = code_generator_for_seq(pen, s.actions)
    :(
        if $(s.predicate)($pen)
            $(codes...)
        end
    )
end

function group_by_type(x)
    isempty(x) && return []
    hd = x[1]
    t = typeof(hd)
    ret = []
    current_group = t[hd]
    for e in x[2:end]
        if e isa t
            push!(current_group, e)
        else
            push!(ret, current_group)
            t = typeof(e)
            current_group = t[e]
        end
    end
    push!(ret, current_group)
    ret
end

function code_generator_for_seq(pen::Code, actions::AbstractArray{Statement})
    ret = []
    for g in group_by_type(actions)
        if g isa Vector{Forward}
            stmt = Forward(sum(i.distance for i in g))
            push!(ret, code_generator(pen, stmt))
        elseif g isa Vector{Turn}
            stmt = Turn(sum(i.angle for i in g))
            push!(ret, code_generator(pen, stmt))
        else
            for each in g
                push!(ret, code_generator(pen, each))
            end
        end
    end
    ret
end

## Compiler targeting Julia
function compile_program(pen::Code, actions::AbstractArray{Statement})
    Expr(:block,
        :(dist :: Float64 = 0),
        :(x :: Float64 = 0),
        :(y :: Float64 = 0),
        :(Δx :: Float64 = 0),
        :(Δy :: Float64 = 0),
        code_generator_for_seq(pen, actions)...
    )
end

end