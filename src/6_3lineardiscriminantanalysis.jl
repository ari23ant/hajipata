using PyPlot
using RDatasets
using DataFrames
using Statistics
using LinearAlgebra

data = Dict{Symbol, Any}()
data[:iris] = dataset("datasets", "iris")
data[:setosa] = data[:iris][data[:iris].Species .== "setosa", setdiff(names(data[:iris]), ["Species"])]
data[:versicolor] = data[:iris][data[:iris].Species .== "versicolor", setdiff(names(data[:iris]), ["Species"])]
data[:virginica] = data[:iris][data[:iris].Species .== "virginica", setdiff(names(data[:iris]), ["Species"])]

rslt = Dict{Symbol, Any}()

function process(data::Dict{Symbol, Any}, rslt::Dict{Symbol, Any})
    println("Main process")

    # 花弁の長さ-幅を描画
    plot_petallength_petalwidth(data[:setosa], data[:versicolor], data[:virginica],
                                "PetalLength", "PetalWidth", xlim=[0.8, 7.2], ylim=[-1.5, 4.0], title="Iris")

    # クラス内変動（各クラスの分散共分散行列）
    Sigma_s = cov(Matrix(data[:setosa]), corrected=true)
    Sigma_c = cov(Matrix(data[:versicolor]), corrected=true)
    Sigma_v = cov(Matrix(data[:virginica]), corrected=true)
    myprint("Sigma_s =", Sigma_s, "Sigma_c =", Sigma_c, "Sigma_v =", Sigma_v)

    # 全クラス内変動
    Sigma_W = Sigma_s + Sigma_c + Sigma_v
    myprint("Sigma_W =", Sigma_W)

    # 全変動（全平均の全データの変動の和）
    Sigma_T = cov(Matrix(data[:iris][:, setdiff(names(data[:iris]), ["Species"])]), corrected=true)
    myprint("Sigma_T =", Sigma_T)

    # クラス間変動｜全変動 = 全クラス内変動 + クラス間変動
    Sigma_B = Sigma_T - Sigma_W
    myprint("Sigma_B =", Sigma_B)

    rslt[:Sigma_W], rslt[:Sigma_T], rslt[:Sigma_B] = Sigma_W, Sigma_T, Sigma_B

    # クラス平均
    M_setosa = mean.(eachcol(data[:setosa]))
    M_versicolor = mean.(eachcol(data[:versicolor]))
    M_virginica = mean.(eachcol(data[:virginica]))
    M = [M_setosa'; M_versicolor'; M_virginica']
    myprint("Group means M=", M)

    rslt[:M] = M

    # 固有値と固有ベクトル
    Sigma_X = inv(Sigma_W) * Sigma_B
    eigenvalue, eigenvector = eigen(Sigma_X, sortby=x->-x)  # 大きい順
    myprint("eigenvalue", eigenvalue, "eigenvector", eigenvector)

    rslt[:Sigma_X], rslt[:eigenvalue], rslt[:eigenvector] = Sigma_X, eigenvalue, eigenvector

    # y切片
    b = mean.(eachcol(M * eigenvector[:, 1:2]))
    myprint("b", b)
    rslt[:b] = b

    LD1param = [eigenvector[1, 1], eigenvector[2, 1], eigenvector[3, 1] ,eigenvector[4, 1], b[1]]
    LD2param = [eigenvector[1, 2], eigenvector[2, 2], eigenvector[3, 2] ,eigenvector[4, 2], b[2]]
    myprint("LD1 paramters", LD1param, "LD2 paramters", LD2param)

    LDiris = fLD(data[:iris], LD1param, LD2param)

    rslt[:LDiris] = LDiris

    plot_LD1_LD2(LDiris, "LD1", "LD2", title="LD iris")
    #plot_LD1_LD2(LDiris, "LD1", "LD2", xlim=[-10, 10], ylim=[-8, 8], title="LD iris")


    println("Done")
end

function plot_LD1_LD2(df::DataFrame, xlabel::String, ylabel::String; xlim::Any=nothing, ylim::Any=nothing, title::String="")::Figure

    setosa = df[df.Species .== "setosa", setdiff(names(df), ["Species"])]
    versicolor = df[df.Species .== "versicolor", setdiff(names(df), ["Species"])]
    virginica = df[df.Species .== "virginica", setdiff(names(df), ["Species"])]

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

function fLD(df::DataFrame, LD1param::Vector, LD2param::Vector)::DataFrame
    num = length(df[:, begin])
    LD1 = Vector{Float64}(undef, num)
    LD2 = Vector{Float64}(undef, num)

    #tgtmat = Matrix(data[:iris][:, setdiff(names(data[:iris]), ["Species"])])
    tgtmat = Matrix(data[:iris][:, [:SepalLength, :SepalWidth, :PetalLength, :PetalWidth]])

    for i in 1:num
        LD1[i] = LD1param[1] * tgtmat[i, 1] + LD1param[2] * tgtmat[i, 2] + LD1param[3] * tgtmat[i, 3] + LD1param[4] * tgtmat[i, 4] + LD1param[5]
        LD2[i] = LD2param[1] * tgtmat[i, 1] + LD2param[2] * tgtmat[i, 2] + LD2param[3] * tgtmat[i, 3] + LD2param[4] * tgtmat[i, 4] + LD2param[5]
    end

    ret = DataFrame(LD1=LD1, LD2=LD2, Species=data[:iris][:, :Species])

    return ret
end

function plot_petallength_petalwidth(setosa::DataFrame, versicolor::DataFrame, virginica::DataFrame, xlabel::String, ylabel::String; xlim::Any=nothing, ylim::Any=nothing, title::String="")::Figure
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
