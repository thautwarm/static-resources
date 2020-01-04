include("terminal-plot-compiler.jl")
include("terminal-plot-high-order.jl")
using BenchmarkTools

always_true(_) = true

macro mk_logic_sample(M)
    quote
        actions = [
            $M.Forward(0.2),
            $M.Forward(0.05),
            $M.Forward(0.05),
            
            $M.Turn(0.1),
            $M.Turn(0.1),

            $M.Forward(0.1),
            $M.Forward(0.2),

            $M.Turn(0.1),
            $M.Turn(0.1),

            $M.Forward(0.1),
            $M.Forward(0.1),

            $M.Forward(0.01),
            $M.Forward(0.01),
            $M.Forward(0.01),
            $M.Forward(0.01),
            $M.Forward(0.01),
    
            $M.Forward(0.02),
            $M.Forward(0.02),
            $M.Turn(0.1),
            $M.Forward(0.2),
    

            $M.When(
                always_true,
                [
                    $M.Forward(-0.2),
                    $M.Turn(-0.1),

                    $M.Forward(-0.01),
                    $M.Forward(-0.03),
                    $M.Forward(-0.01),

                    $M.Forward(-0.02),
                    $M.Forward(-0.02),
            
                    $M.Forward(-0.1),
                    $M.Forward(-0.1),
                    $M.Turn(-0.1),
                    $M.Turn(-0.1),
                    $M.Forward(-0.1),
                    $M.Forward(-0.2),
                    
                    $M.Turn(-0.1),
                    $M.Turn(-0.1),
                    
                    $M.Forward(-0.05),
                    $M.Forward(-0.05),
                    $M.Forward(-0.2),
                ]
            ),            
        ]

        actions
    end

end

t1 = @mk_logic_sample TagfulHighOrder
p1 = TagfulHighOrder.Pen((40, 10))

t2 = @mk_logic_sample TagfulCompiler
p2 = TagfulCompiler.Pen((40, 10))

@info :interpretation
@btime $TagfulHighOrder.interpret_dsl($p1, $t1)

@info :compile_time
@btime $TagfulCompiler.compile_program($p2, $t2)

code = TagfulCompiler.compile_program(p2, t2)

const compiled_func = eval(:(() -> $code))
compiled_func()

@info :compiled_func
@btime $compiled_func()


