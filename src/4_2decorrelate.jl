using PyPlot
using RDatasets
using DataFrames
using Statistics
using LinearAlgebra

data = Dict{String, Any}()
data["iris"] = dataset("datasets", "iris")
data["setosa"] = data["iris"][data["iris"].Species .== "setosa", :]
data["versicolor"] = data["iris"][data["iris"].Species .== "versicolor", :]
data["virginica"] = data["iris"][data["iris"].Species .== "virginica", :]

rslt = Dict{String, Any}()

function process(data::Dict{String, Any}, rslt::Dict{String, Any})
    println("Main process")

    # 花弁の長さ-幅を描画
    plot_petallength_petalwidth(data["setosa"], data["versicolor"], data["virginica"], "PetalLength", "PetalWidth", [0.8, 7.2], [-1.5, 4.0])

    # --- 実行例4.1を復習｜ライブラリ使用
    # 平均
    avg_irispl = mean(data["iris"][!, "PetalLength"])
    avg_irispw = mean(data["iris"][!, "PetalWidth"])
    myprint("Mean is", [avg_irispl avg_irispw])

    # 分散｜N-1不偏分散
    var_irispl = var(data["iris"][!, "PetalLength"], corrected=true)
    var_irispw = var(data["iris"][!, "PetalWidth"], corrected=true)
    myprint("Variances are", var_irispl, var_irispw)

    # 共分散｜N-1不偏分散
    var_irisplpw = cov(data["iris"][!, "PetalLength"], data["iris"][!, "PetalWidth"], corrected=true)

    # 分散共分散行列
    covmatrix = [var_irispl var_irisplpw;
                 var_irisplpw var_irispw]

    rslt["μ"] = [avg_irispl avg_irispw]
    rslt["Σ"] = covmatrix

    # 計算結果を確認
    myprint("μ is", [avg_irispl avg_irispw], "Σ is", covmatrix)

    # 固有値と固有ベクトル（正規直交行列）を計算｜eigvalsとeigvecsでもOK
    eigenvalue, eigenvector = eigen(covmatrix)
    #eigenvalue, eigenvector = eigen(covmatrix, sortby=x->-x)
    myprint("λ is", eigenvalue, "S is", eigenvector)

    rslt["S"] = eigenvector

    # 計算の確認｜固有値が出るかどうか
    myprint(inv(eigenvector) * covmatrix * eigenvector)

    # 無相関化
    x = Matrix(data["iris"][!, ["PetalLength", "PetalWidth"]])
    #y = x * eigenvector
    y = decorrelate(x)  # 関数としてまとめた
    vec_decor_irispl = y[:, 1]
    vec_decor_irispw = y[:, 2]

    # 計算結果を格納
    decor_iris = data["iris"][!, ["PetalLength", "PetalWidth", "Species"]]
    decor_iris[!, "PetalLength"] = vec_decor_irispl
    decor_iris[!, "PetalWidth"] = vec_decor_irispw
    rslt["iris"] = decor_iris

    # 花弁の長さ-幅を描画｜無相関化
    plot_petallength_petalwidth(rslt["iris"][rslt["iris"].Species .== "setosa", :],
                                rslt["iris"][rslt["iris"].Species .== "versicolor", :],
                                rslt["iris"][rslt["iris"].Species .== "virginica", :],
                                "PetalLength", "PetalWidth", [-2.2, 3.2])

    println("Done")
end

function decorrelate(mat::Matrix)::Matrix
    # 分散共分散行列
    Σ = cov(mat)

    # 固有値と固有ベクトル（正規直交行列）
    λ, S = eigen(Σ)
    myprint("Eigen values λ is", λ, "Eigen vectors S is", S)
    myprint("Diagonal elements are", inv(S) * Σ * S)

    # 線形変換
    ret = mat * S

    return ret
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
        myshow(p)
    end
end
myshow(arg::String) = println(arg)
myshow(arg) = (show(stdout, "text/plain", arg); println())

# ***** Main process *****
#process(data)
process(data, rslt)

#if abspath(PROGRAM_FILE) == @__FILE__
#    process(data)
#end
