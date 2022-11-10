using PyPlot
using RDatasets
using DataFrames

data = Dict{Symbol, Any}()
data[:iris] = dataset("datasets", "iris")
data[:setosa] = data[:iris][data[:iris].Species .== "setosa", setdiff(names(data[:iris]), ["Species"])]
data[:versicolor] = data[:iris][data[:iris].Species .== "versicolor", setdiff(names(data[:iris]), ["Species"])]
data[:virginica] = data[:iris][data[:iris].Species .== "virginica", setdiff(names(data[:iris]), ["Species"])]

rslt = Dict{Symbol, Any}()

function process(data::Dict{Symbol, Any}, rslt::Dict{Symbol, Any})
    println(" ------- Main process ------- ")

    # setosa, versicolor, virginicaを描画
    #plot_setosa_versicolor_virginica(data[:setosa], data[:versicolor], data[:virginica], "PetalLength", "PetalWidth", title="Iris")

    # setosa + virginica -> x(xx), versicolor -> c(cc)
    xx = [data[:setosa]; data[:virginica]]
    cc = data[:versicolor]

    # 特徴を絞る
    feat1, feat2 = :PetalLength, :PetalWidth
    xx = xx[:, [feat1, feat2]]
    cc = cc[:, [feat1, feat2]]
    rslt[:xx], rslt[:cc] = xx, cc

    plot_sampledata(xx, cc)

    println(" -------     Done     ------- ")
end

function plot_sampledata(xx, cc)
    fig, ax = subplots()
    ax.scatter(xx[:, 1], xx[:, 2], marker="\$x\$", label="s+v")
    ax.scatter(cc[:, 1], cc[:, 2], marker="\$c\$", label="c")
    ax.set_xlabel(names(xx)[1])
    ax.set_ylabel(names(xx)[2])
    grid()
    legend()
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
