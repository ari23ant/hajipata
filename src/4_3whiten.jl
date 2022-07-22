using PyPlot
using RDatasets
using DataFrames
using Statistics
using LinearAlgebra

data = Dict{Symbol, Any}()
data[:iris] = dataset("datasets", "iris")
data[:setosa] = data[:iris][data[:iris].Species .== "setosa", :]
data[:versicolor] = data[:iris][data[:iris].Species .== "versicolor", :]
data[:virginica] = data[:iris][data[:iris].Species .== "virginica", :]

rslt = Dict{Symbol, Any}()

function process(data::Dict{Symbol, Any}, rslt::Dict{Symbol, Any})
    println("Main process")

    # 花弁の長さ-幅を描画
    plot_petallength_petalwidth(data[:setosa], data[:versicolor], data[:virginica],
                                "PetalLength", "PetalWidth", [0.8, 7.2], [-1.5, 4.0], "Iris")

    # PetalLengthとPetalWidthを抜き出す
    tgtmat = Matrix(data[:iris][!, ["PetalLength", "PetalWidth"]])

    # ------- 標準化
    # 平均
    μ = [mean(tgtmat[:, 1]), mean(tgtmat[:, 2])]
    myprint("μ is", μ)

    # 分散共分散行列｜N-1不偏分散
    Σ = cov(tgtmat, corrected=true)
    myprint("Σ is", Σ)

    # 標準化
    std_irispl = standardize(tgtmat[:, 1])
    std_irispw = standardize(tgtmat[:, 2])

    # 計算結果を格納
    std_iris = data[:iris][!, ["PetalLength", "PetalWidth", "Species"]]
    std_iris[!, "PetalLength"] = std_irispl
    std_iris[!, "PetalWidth"] = std_irispw
    rslt[:std] = std_iris

    # 花弁の長さ-幅を描画
    plot_petallength_petalwidth(rslt[:std][rslt[:std].Species .== "setosa", :],
                                rslt[:std][rslt[:std].Species .== "versicolor", :],
                                rslt[:std][rslt[:std].Species .== "virginica", :],
                                "PetalLength", "PetalWidth", nothing, nothing, "Standardization")

    # ------- 無相関化
    # 固有値と固有ベクトル（正規直交行列）を計算｜eigvalsとeigvecsでもOK
    λ, S = eigen(Σ)
    myprint("λ is", λ, "S is", S)

    # 計算の確認｜固有値が出るかどうか
    #myprint(inv(S) * Σ * S)

    # 無相関化
    y1 = decorrelate(tgtmat)
    decor_irispl = y1[:, 1]
    decor_irispw = y1[:, 2]

    # 計算結果を格納
    decor_iris = data[:iris][!, ["PetalLength", "PetalWidth", "Species"]]
    decor_iris[!, "PetalLength"] = decor_irispl
    decor_iris[!, "PetalWidth"] = decor_irispw
    rslt[:decor] = decor_iris

    # 花弁の長さ-幅を描画｜無相関化
    plot_petallength_petalwidth(rslt[:decor][rslt[:decor].Species .== "setosa", :],
                                rslt[:decor][rslt[:decor].Species .== "versicolor", :],
                                rslt[:decor][rslt[:decor].Species .== "virginica", :],
                                "PetalLength", "PetalWidth", [-2.2, 3.2], nothing, "Decorrelation")

    # ------- 白色化
    # 固有値の対角ベクトル
    Λ = Diagonal(λ)
    myprint(Λ)

    # 計算結果を入れるMatrix用意
    calmat = tgtmat

    # 白色化
    calmat[:, 1] = tgtmat[:, 1] .- μ[1]
    calmat[:, 2] = tgtmat[:, 2] .- μ[2]
    calmat = calmat * transpose(S) * inv(sqrt(Λ))  # テキストと逆だが、各ベクトルの形を考慮している

    # 計算結果を格納
    whtn_iris = data[:iris][!, ["PetalLength", "PetalWidth", "Species"]]
    whtn_iris[!, "PetalLength"] = calmat[:, 1]
    whtn_iris[!, "PetalWidth"] = calmat[:, 2]
    rslt[:whtn] = whtn_iris

    # 計算の確認｜分散共分散行列の対角要素に1、非対角要素に0が並ぶか
    #myprint(cov(calmat))

    # 花弁の長さ-幅を描画｜無相関化
    plot_petallength_petalwidth(rslt[:whtn][rslt[:whtn].Species .== "setosa", :],
                                rslt[:whtn][rslt[:whtn].Species .== "versicolor", :],
                                rslt[:whtn][rslt[:whtn].Species .== "virginica", :],
                                "PetalLength", "PetalWidth", nothing, [-3.2, 2.9], "Whitening")

    println("Done")
end

#function whiten(mat::Matrix{Float64})::Matrix{Float64}
#end

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

function standardize(vec::Vector{Float64})::Vector{Float64}
    avg = mean(vec)
    std = sqrt(var(vec))
    z = (vec .- avg) ./ std
    return z
end

function plot_petallength_petalwidth(setosa::DataFrame, versicolor::DataFrame, virginica::DataFrame, xlabel::String, ylabel::String, xlim::Any=nothing, ylim::Any=nothing, title::String="")::Figure
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
function myprint(param...)
    for p in param
        myshow(p)
    end
end
myshow(arg::String) = println(arg)
myshow(arg) = (show(stdout, "text/plain", arg); println())

# ***** Main process *****
process(data, rslt)

#if abspath(PROGRAM_FILE) == @__FILE__
#    process(data)
#end
