using PyPlot
using RDatasets
using DataFrames
using Statistics
using LinearAlgebra

data = Dict{Symbol, Any}()
data[:pimatr] = dataset("MASS", "Pima.tr")
data[:pos] = data[:pimatr][data[:pimatr].Type .== "Yes", :]
data[:neg] = data[:pimatr][data[:pimatr].Type .== "No", :]
data[:pimate] = dataset("MASS", "Pima.te")

rslt = Dict{Symbol, Any}()

function process(data::Dict{Symbol, Any}, rslt::Dict{Symbol, Any})
    println("Main process")

    # Glu-BMIで描画
    #plotGluBMI(data[:pimatr], title="Pima training")

    # YesとNoでGluとBMIを抜き出す
    tgtpos = Matrix(data[:pos][!, [:Glu, :BMI]])
    tgtneg = Matrix(data[:neg][!, [:Glu, :BMI]])

    rslt[:pos], rslt[:neg] = tgtpos, tgtneg

    # 平均ベクトル
    mupos = [mean(tgtpos[:, 1]), mean(tgtpos[:, 2])]
    muneg = [mean(tgtneg[:, 1]), mean(tgtneg[:, 2])]

    rslt[:mupos], rslt[:muneg] = mupos, muneg

    # 分散共分散行列｜N-1不偏分散
    Sigmapos = cov(tgtpos, corrected=true)
    Sigmaneg = cov(tgtneg, corrected=true)

    rslt[:Sigmapos], rslt[:Sigmaneg] = Sigmapos, Sigmaneg

    # 事前確率
    Ppos = length(tgtpos[:, 1]) / (length(tgtpos[:, 1]) + length(tgtneg[:, 1]))
    Pneg = length(tgtneg[:, 1]) / (length(tgtpos[:, 1]) + length(tgtneg[:, 1]))

    rslt[:Ppos], rslt[:Pneg] = Ppos, Pneg

    # --- 2次識別関数 QDF: Quadratic Discriminant Function
    # 2次識別関数のパラメタ計算
    QDF_S = inv(Sigmapos) - inv(Sigmaneg)
    QDF_c = (muneg' * inv(Sigmaneg) - mupos' * inv(Sigmapos))'
    QDF_F = (mupos' * inv(Sigmapos) * mupos - muneg' * inv(Sigmaneg) * muneg
             + log(det(Sigmapos) / det(Sigmaneg)) - 2 * log(Ppos / Pneg))

    rslt[:QDF_S], rslt[:QDF_c], rslt[:QDF_F] = QDF_S, QDF_c, QDF_F

    # 2次識別関数の境界線計算
    numx, numy = 200, 100  # 刻み数
    gridx = range(minimum(data[:pimatr].Glu), maximum(data[:pimatr].Glu), numx)
    gridy = range(minimum(data[:pimatr].BMI), maximum(data[:pimatr].BMI), numy)

    QDF_z = qdfmesh(gridx, gridy, QDF_S, QDF_c, QDF_F, 0.)

    rslt[:QDF_z] = QDF_z

    # 2次識別関数の境界線プロット
    #contourGluBMI(data[:pimatr], (gridx, gridy, reshape(QDF_z, numy, numx)), title="Quadratic discriminant function")

    # --- 線形識別関数 LDF: Liner Discriminant Function
    # 共通の分散共分散行列
    Sigmapool = Ppos * Sigmapos + Pneg * Sigmaneg

    rslt[:Sigmapool] = Sigmapool

    # 線形識別関数のパラメタ計算
    LDF_S = inv(Sigmapool) - inv(Sigmapool)  # zeros(2, 2)と等価
    LDF_c = (muneg' * inv(Sigmapool) - mupos' * inv(Sigmapool))'
    LDF_F = (mupos' * inv(Sigmapool) * mupos - muneg' * inv(Sigmapool) * muneg
             + log(det(Sigmapool) / det(Sigmapool)) - 2 * log(Ppos / Pneg))  # log(det(Sigmapool) / det(Sigmapool)) = 0.0

    rslt[:LDF_S], rslt[:LDF_c], rslt[:LDF_F] = LDF_S, LDF_c, LDF_F

    # 線形識別関数の境界線計算｜2次識別関数と条件を揃える
    LDF_z = qdfmesh(gridx, gridy, LDF_S, LDF_c, LDF_F, 0.)  # qdfmeshを使い回す

    rslt[:LDF_z] = LDF_z

    # 線形識別関数の境界線プロット
    #contourGluBMI(data[:pimatr], (gridx, gridy, reshape(LDF_z, numy, numx)), title="Liner discriminant function")

    # --- 誤り率
    qdftrerr = qdferror(data[:pimatr][!, [:Glu, :BMI, :Type]], QDF_S, QDF_c, QDF_F, 0.)
    myprint("QDF training error[%]", qdftrerr*100)

    ldftrerr = qdferror(data[:pimatr][!, [:Glu, :BMI, :Type]], LDF_S, LDF_c, LDF_F, 0.)
    myprint("LDF training error[%]", ldftrerr*100)

    qdfteerr = qdferror(data[:pimate][!, [:Glu, :BMI, :Type]], QDF_S, QDF_c, QDF_F, 0.)
    myprint("QDF test error[%]", qdfteerr*100)

    ldfteerr = qdferror(data[:pimate][!, [:Glu, :BMI, :Type]], LDF_S, LDF_c, LDF_F, 0.)
    myprint("LDF test error[%]", ldfteerr*100)

    # --- ROC曲線



    println("Done")
end

function qdfmesh(gridx::StepRangeLen, gridy::StepRangeLen, S::Matrix{Float64}, c::Vector{Float64}, F::Float64, thres::Float64)
    numx, numy = length(gridx), length(gridy)
    x = vec(gridx' .* ones(numy))
    y = vec(ones(numx)' .* gridy)

    numz = numx * numy
    z = zeros(numz)

    for i in 1:numz
        z[i] = qdf(x[i], y[i], S, c, F, thres)
    end

    return z
end

function qdf(x::Float64, y::Float64, S::Matrix{Float64}, c::Vector{Float64}, F::Float64, thres::Float64)
    X = [x, y]
    Y = X' * S * X + 2 * c' * X + F
    Y = Y < thres ? 1. : 0.
    return Y
end

function qdf(X::Matrix{Float64}, S::Matrix{Float64}, c::Vector{Float64}, F::Float64, thres::Float64)
    num = length(X[:, 1])
    Y = Vector{Float64}(undef, num)

    for i in 1:num
        Y[i] = qdf(X[i, 1], X[i, 2], S, c, F, thres)
    end

    return Y
end

function qdferror(X::DataFrame, S::Matrix{Float64}, c::Vector{Float64}, F::Float64, thres::Float64)
    num = length(X[:, 1])
    #Y = Vector{Float64}(undef, num)
    numerror = 0

    for i in 1:num
        z = qdf(Float64(X[i, 1]), Float64(X[i, 2]), S, c, F, thres)

        if z == 1.0 && X[i, 3] == "No"
            numerror += 1
        elseif z == 0.0 && X[i, 3] == "Yes"
            numerror += 1
        end
    end

    ret = numerror / num
    return ret
end

function contourGluBMI(pima::DataFrame, contour::Tuple; xlim::Any=nothing, ylim::Any=nothing, title::String="")::Figure
    pos = pima[pima.Type .== "Yes", :]
    neg = pima[pima.Type .== "No", :]

    fig, ax = subplots()
    if title!="" fig.suptitle(title) end
    ax.scatter(pos[!, :Glu], pos[!, :BMI], marker="o", label="Yes")
    ax.scatter(neg[!, :Glu], neg[!, :BMI], marker="^", label="No")
    if !isnothing(xlim) ax.set_xlim(xlim) end
    if !isnothing(ylim) ax.set_ylim(ylim) end
    ax.contour(contour[1], contour[2], contour[3], colors="green")
    ax.set_xlabel("Glu")
    ax.set_ylabel("BMI")
    grid(b=true)
    legend()
end

function plotGluBMI(pima::DataFrame; xlim::Any=nothing, ylim::Any=nothing, title::String="")::Figure
    pos = pima[pima.Type .== "Yes", :]
    neg = pima[pima.Type .== "No", :]

    fig, ax = subplots()
    if title!="" fig.suptitle(title) end
    ax.scatter(pos[!, :Glu], pos[!, :BMI], marker="o", label="Yes")
    ax.scatter(neg[!, :Glu], neg[!, :BMI], marker="^", label="No")
    if !isnothing(xlim) ax.set_xlim(xlim) end
    if !isnothing(ylim) ax.set_ylim(ylim) end
    ax.set_xlabel("Glu")
    ax.set_ylabel("BMI")
    grid(b=true)
    legend()
end

# -*-*-*- Utilities -*-*-*-
myprint(args...) = (for arg in args myshow(arg) end)
myshow(arg::String) = println(arg)
myshow(arg) = (show(stdout, "text/plain", arg); println())

# -*-*-*- Main process -*-*-*-
process(data, rslt)

#if abspath(PROGRAM_FILE) == @__FILE__
#    process(data, rslt)
#end
