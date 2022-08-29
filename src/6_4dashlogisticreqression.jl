using PyPlot
using RDatasets
using DataFrames
using Statistics
using LinearAlgebra
using Random

data = Dict{Symbol, Any}()
data[:iris] = dataset("datasets", "iris")
data[:setosa] = data[:iris][data[:iris].Species .== "setosa", setdiff(names(data[:iris]), ["Species"])]
data[:versicolor] = data[:iris][data[:iris].Species .== "versicolor", setdiff(names(data[:iris]), ["Species"])]
data[:virginica] = data[:iris][data[:iris].Species .== "virginica", setdiff(names(data[:iris]), ["Species"])]

rslt = Dict{Symbol, Any}()

function process(data::Dict{Symbol, Any}, rslt::Dict{Symbol, Any})
    println("Main process")

    # setosa, versicolor, virginicaを描画
    #plot_setosa_versicolor_virginica(data[:setosa], data[:versicolor], data[:virginica], "PetalLength", "PetalWidth", title="Iris")
    #plot_setosa_versicolor_virginica(data[:setosa], data[:versicolor], data[:virginica], "SepalLength", "SepalWidth", title="Iris")

    # 分類するデータを整理
    X1, X2 = :PetalLength, :PetalWidth
    pos, neg = :setosa, :versicolor
    dftgt = maketargetdataframe(data[:iris], pos, neg, X1, X2)
    dfpos = dftgt[dftgt.class .== 1, :]
    dfneg = dftgt[dftgt.class .== 0, :]

    rslt[:dftgt], rslt[:dfpos], rslt[:dfneg] = dftgt, dfpos, dfneg

    # 重みの初期化
    seed = 23
    weight = setweight(3, seed)
    myprint(weight)

    myprint(sigmoid(Vector(dftgt[1, 1:2]), weight))

    println("Done")
end

function sigmoid(x::Vector, w::Vector)
    a = w[1:2]' * x + w[3]
    f = 1.0 / (1.0 + exp(-a))
    return f
end

function setweight(size::Int, seed::Int)
    Random.seed!(seed)
    weight = rand(size)
    return weight
end

function maketargetdataframe(df::DataFrame, pos::Symbol, neg::Symbol, X1::Symbol, X2::Symbol)
    dfpos = df[df.Species .== string(pos), [X1, X2]]
    dfpos[!, :class] .= 1

    dfneg = df[df.Species .== string(neg), [X1, X2]]
    dfneg[!, :class] .= 0

    dftgt = vcat(dfpos, dfneg)

    #return dftgt, dfpos, dfneg
    return dftgt
end

function plot_setosa_versicolor_virginica(setosa::DataFrame, versicolor::DataFrame, virginica::DataFrame, xlabel::String, ylabel::String; xlim::Any=nothing, ylim::Any=nothing, title::String="")::Figure
    fig, ax = subplots()
    if title!="" fig.suptitle(title) end
    ax.scatter(setosa[!, xlabel], setosa[!, ylabel], marker="\$s\$", label="setosa")
    ax.scatter(versicolor[!, xlabel], versicolor[!, ylabel], marker="\$c\$", label="versicolor")
    ax.scatter(virginica[!, xlabel], virginica[!, ylabel], marker="\$v\$", label="virginica")
    if !isnothing(xlim) ax.set_xlim(xlim) end
    if !isnothing(ylim) ax.set_ylim(ylim) end
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    grid()
    legend()
    return fig
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
