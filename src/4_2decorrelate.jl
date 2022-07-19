using PyPlot
using RDatasets
using DataFrames
using Statistics
using LinearAlgebra

iris = dataset("datasets", "iris")
#println(names(iris))  # 列見出しを確認
#println(levels(iris.Species))  # アヤメの種類を確認

data = Dict{String, Any}()
data["iris"] = iris
data["setosa"] = iris[iris.Species .== "setosa", :]
data["versicolor"] = iris[iris.Species .== "versicolor", :]
data["virginica"] = iris[iris.Species .== "virginica", :]

function process(data::Dict)
    println("Main process")

    # 花弁の長さ-幅を描画
    #plot_petallength_petalwidth(data["setosa"], data["versicolor"], data["virginica"], "PetalLength", "PetalWidth")
    plot_petallength_petalwidth(data["setosa"], data["versicolor"], data["virginica"], "PetalLength", "PetalWidth", [0.8, 7.2], [-1.5, 4.0])

    # 平均
    avg_irispl = mean(data["iris"][!, "PetalLength"])
    avg_irispw = mean(data["iris"][!, "PetalWidth"])
    myprint(avg_irispl, avg_irispw)

    # 分散｜N-1不偏分散
    var_irispl = var(data["iris"][!, "PetalLength"], corrected=true)
    var_irispw = var(data["iris"][!, "PetalWidth"], corrected=true)
    myprint(var_irispl, var_irispw)

    # 共分散｜N-1不偏分散
    var_irisplpw = cov(data["iris"][!, "PetalLength"], data["iris"][!, "PetalWidth"], corrected=true)

    # 分散共分散行列
    covmatrix = [var_irispl var_irisplpw;
                 var_irisplpw var_irispw]

    # 計算結果を確認
    myprint([avg_irispl avg_irispw], covmatrix)

    myprint(eigvals(covmatrix, sortby=x->-x))

    """
    # 標準化
    vec_std_irispl = standardize(data["iris"][!, "PetalLength"])
    vec_std_irispw = standardize(data["iris"][!, "PetalWidth"])

    # 計算結果を格納
    std_iris = data["iris"][!, ["PetalLength", "PetalWidth", "Species"]]
    std_iris[!, "PetalLength"] = vec_std_irispl
    std_iris[!, "PetalWidth"] = vec_std_irispw
    data["std_iris"] = std_iris

    # 花弁の長さ-幅を描画｜標準化
    plot_petallength_petalwidth(data["std_iris"][data["std_iris"].Species .== "setosa", :],
                                data["std_iris"][data["std_iris"].Species .== "versicolor", :],
                                data["std_iris"][data["std_iris"].Species .== "virginica", :],
                                "PetalLength", "PetalWidth")
    """

    println("Done")
end

function plot_petallength_petalwidth(setosa::DataFrame, versicolor::DataFrame, virginica::DataFrame, xlabel::String, ylabel::String, xlim::Any=nothing, ylim::Any=nothing)::Figure
    fig, ax = subplots()
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
function myprint(param...)
    for p in param
        show(stdout, "text/plain", p)
        println()  # 改行
    end
end

# ***** Main process *****
process(data)

#if abspath(PROGRAM_FILE) == @__FILE__
#    process(data)
#end
