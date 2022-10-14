using PyPlot
#using RDatasets
#using DataFrames
#using Statistics
#using LinearAlgebra
#using Random

data = Dict{Symbol, Any}()
data[:X0] = [ 1.76405235  0.40015721;
              0.97873798  2.2408932 ;
              1.86755799 -0.97727788;
              0.95008842 -0.15135721;
             -0.10321885  0.4105985 ;
              0.14404357  1.45427351;
              0.76103773  0.12167502;
              0.44386323  0.33367433;
              1.49407907 -0.20515826;
              0.3130677  -0.85409574;
             -2.55298982  0.6536186 ;
              0.8644362  -0.74216502;
              2.26975462 -1.45436567;
              0.04575852 -0.18718385;
              1.53277921  1.46935877;
              0.15494743  0.37816252;
             -0.88778575 -1.98079647;
             -0.34791215  0.15634897;
              1.23029068  1.20237985;
             -0.38732682 -0.30230275 ]

data[:X1] = [ 3.95144703  3.57998206;
              3.29372981  6.9507754 ;
              4.49034782  4.5619257 ;
              3.74720464  5.77749036;
              3.38610215  4.78725972;
              4.10453344  5.3869025 ;
              4.48919486  3.81936782;
              4.97181777  5.42833187;
              5.06651722  5.3024719 ;
              4.36567791  4.63725883;
              4.32753955  4.64044684;
              4.18685372  3.2737174 ;
              5.17742614  4.59821906;
              3.36980165  5.46278226;
              4.09270164  5.0519454 ;
              5.72909056  5.12898291;
              6.13940068  3.76517418;
              5.40234164  4.31518991;
              4.12920285  4.42115034;
              4.68844747  5.05616534 ]

data[:y] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]

rslt = Dict{Symbol, Any}()

function process(data::Dict{Symbol, Any}, rslt::Dict{Symbol, Any})
    println("Main process")

    # 訓練データプロット
    plottraindata(data[:X0], data[:X1])

    # モデル初期化
    m = initSVMhard(length(data[:X0][:, 1]))
    myprint(m)


    println("Done")
end

struct SVMhard
    a::Vector
    w::Vector
    b::Float64
end

function initSVMhard(len)
    a = [0 for i in 1:len]
    w = [0.0 for i in 1:len]
    b = 0.0
    m = SVMhard(a, w, b)
    return m
end

function fit(m::SVMhard)

end

function plottraindata(X0, X1)
    fig, ax = subplots()
    ax.set_aspect("equal")
    ax.scatter(X0[:, 1], X0[:, 2], color="k", marker="+")
    ax.scatter(X1[:, 1], X1[:, 2], color="k", marker="*")
end

# ***** utilities *****
# ref: https://discourse.julialang.org/t/how-to-get-a-function-to-print-stuff-with-repl-like-formatting/45877
myprint(args...) = (for arg in args myshow(arg) end)
myshow(arg::String) = println(arg)
myshow(arg) = (show(stdout, "text/plain", arg); println())

# ***** Main process *****
process(data, rslt)

#if abspath(PROGRAM_FILE) == @__FILE__
#    process(data)
#end
