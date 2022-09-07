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
    plot_setosa_versicolor_virginica(data[:setosa], data[:versicolor], data[:virginica], "PetalLength", "PetalWidth", title="Iris")
    #plot_setosa_versicolor_virginica(data[:setosa], data[:versicolor], data[:virginica], "SepalLength", "SepalWidth", title="Iris")

    # 分類するデータを抽出
    X1, X2 = :PetalLength, :PetalWidth
    pos, neg = :setosa, :versicolor
    #pos, neg = :versicolor, :virginica
    #X1, X2 = :SepalLength, :SepalWidth
    #pos, neg = :versicolor, :setosa

    dftgt = maketargetdataframe(data[:iris], pos, neg, X1, X2)
    dfpos = dftgt[dftgt.Class .== 1, :]
    dfneg = dftgt[dftgt.Class .== 0, :]

    rslt[:dftgt], rslt[:dfpos], rslt[:dfneg] = dftgt, dfpos, dfneg

    # 重みの初期化
    seed = 23
    weight = setweight(3, seed)
    myprint(weight)

    myprint(sigmoid(Vector(dftgt[1, 1:2]), weight))

    ## 交差エントロピー型誤差関数(test)
    #L = crossentropyerror(dftgt, weight)
    #myprint(L)

    ## Lの傾き(test)
    #dL = gradient(dftgt, weight)
    #myprint(dL)

    # 学習
    num = 100  # 学習回数
    alpha = 0.5  # 学習率
    weight = fit(dftgt, weight, num, alpha)

    myprint("w: ", weight)

    # 2次識別関数の境界線計算
    numx, numy = 200, 100  # 刻み数
    myprint( maximum(dftgt[:, [X1]][:, 1]) )
    gridx = range(minimum(dftgt[:, [X1]][:, 1]), maximum(dftgt[:, [X1]][:, 1]), numx)
    gridy = range(minimum(dftgt[:, [X2]][:, 1]), maximum(dftgt[:, [X2]][:, 1]), numy)

    z = mesh(gridx, gridy, weight, 0.5)

    #rslt[:z] = z

    # 描画
    contouriris(dftgt, (gridx, gridy, reshape(z, numy, numx)), xlim=[0.7, 7.2], ylim=[0, 2.6], title="Logistic regression")

    println("Done")
end

function contouriris(df::DataFrame, contour::Tuple; xlim::Any=nothing, ylim::Any=nothing, title::String="")::Figure
    pos = df[df.Class .== 1, :]
    neg = df[df.Class .== 0, :]

    X1, X2, _ = names(df)

    fig, ax = subplots()
    if title!="" fig.suptitle(title) end
    ax.scatter(pos[!, X1], pos[!, X2], marker="o", label="Yes")
    ax.scatter(neg[!, X1], neg[!, X2], marker="^", label="No")
    if !isnothing(xlim) ax.set_xlim(xlim) end
    if !isnothing(ylim) ax.set_ylim(ylim) end
    ax.contour(contour[1], contour[2], contour[3], colors="green")
    ax.set_xlabel(X1)
    ax.set_ylabel(X2)
    grid(b=true)
    legend()

    return fig
end

function mesh(gridx::StepRangeLen, gridy::StepRangeLen, w::Vector, thres::Float64)
    numx, numy = length(gridx), length(gridy)
    x = vec(gridx' .* ones(numy))
    y = vec(ones(numx)' .* gridy)

    numz = numx * numy
    z = zeros(numz)

    for i in 1:numz
        z[i] = logisticregression([x[i], y[i]], w, thres)
    end

    return z
end


function logisticregression(x::Matrix, w::Vector, thres::Float64)
    num = length(x[:, 1])
    y = Vector{Float64}(undef, num)

    for i in 1:num
        y[i] = logisticregression(x[i, 1:2], w, thres)
    end
    return y
end

function logisticregression(x::Vector, w::Vector, thres::Float64)
    y = sigmoid(x, w)
    ret = y > thres ? 1. : 0.
    return ret
end

function fit(df::DataFrame, w::Vector, num::Int, alpha::Float64)
    weight = copy(w)

    for i = 1:num
        L = crossentropyerror(df, weight)
        dL = gradient(df, weight)
        weight -= alpha * dL

        print("L: ")
        println(L)
    end

    return weight
end

function gradient(df::DataFrame, w::Vector)
    # 3 x 1 のベクトルを返す
    num, _ = size(df)

    tgt = Matrix(df)

    grad = zeros(3)

    for i in 1:num
        xi = tgt[i, :]
        pii = sigmoid(xi[1:2], w)
        ti = xi[3]

        grad += xi * (pii - ti)
        #myprint(grad)
    end

    return grad
end

function crossentropyerror(df::DataFrame, w::Vector)
    num, _ = size(df)

    tgt = Matrix(df)

    L = 0

    for i in 1:num
        xi = tgt[i, :]
        pii = sigmoid(xi[1:2], w)
        ti = xi[3]

        L += - ( ti * log(pii) + (1 - ti) * log(1 - pii) )
        #myprint(pii)
        #myprint(L)
    end

    return L
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
    dfpos[!, :Class] .= 1

    dfneg = df[df.Species .== string(neg), [X1, X2]]
    dfneg[!, :Class] .= 0

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
