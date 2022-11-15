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
    #plot_sampledata(xx, cc)

    # 各軸の最小値と最大値
    plmin = minimum([xx[:, :PetalLength]; cc[:, :PetalLength]])
    plmax = maximum([xx[:, :PetalLength]; cc[:, :PetalLength]])
    pwmin = minimum([xx[:, :PetalWidth]; cc[:, :PetalWidth]])
    pwmax = maximum([xx[:, :PetalWidth]; cc[:, :PetalWidth]])
    println(plmin, plmax)
    println(pwmin, pwmax)


    # まずいまのノードで各クラスの数を数えてgini係数を計算
    # つぎに、分割境界で、2分割され、LとRでそれぞれgini係数を計算
    # 減少率を計算
    # 辞書型で管理？

    node = Dict{Symbol, Any}()

    n = 1

    node[:node] = n
    node[:xx] = xx
    node[:cc] = cc
    numxx = length(node[:xx][:, 1])
    numcc = length(node[:cc][:, 1])
    node[:score] = gini([numxx, numcc])

    total = numxx + numcc

    for pl in plmin+step:step:plmax-step

        left = sum(node[:xx] .> pl) + sum(node[:cc] .> pl)
        right = total - left

        delata = node[:score] - (left/total)

    end

    for pw in pwmin+step:step:pwmax-step

    end


    """
    step = 0.1
    for pl in plmin+step:step:plmax-step
        numxx = sum(xx[:, :PetalLength] .> pl)
        numcc = sum(cc[:, :PetalLength] .> pl)
        score = gini([numxx, numcc])
        println(score)
    end
    println("aaaaaaaaaa")
    for pw in pwmin+step:step:pwmax-step
        numxx = sum(xx[:, :PetalWidth] .> pw)
        numcc = sum(cc[:, :PetalWidth] .> pw)
        score = gini([numxx, numcc])
        println(score)
    end
    """


    println(" -------     Done     ------- ")
end

function gini(nums)
    total = sum(nums)

    gini = 0
    for n in nums
        gini += (n / total) * (1 - n / total)
    end

    return gini
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
