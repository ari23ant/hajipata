using PyPlot
using RDatasets
using DataFrames
using Statistics
using LinearAlgebra

data = Dict{Symbol, Any}()
data[:pimatr] = dataset("MASS", "Pima.tr")
data[:pos] = data[:pimatr][data[:pimatr].Type .== "Yes", :]
data[:neg] = data[:pimatr][data[:pimatr].Type .== "No", :]

rslt = Dict{Symbol, Any}()

function process(data::Dict{Symbol, Any}, rslt::Dict{Symbol, Any})
    println("Main process")

    # Glu-BMIで描画
    plotGluBMI(data[:pimatr], title="Pima training")

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

    # 2次識別関数のパラメタ計算
    # QDF: Quadratic Discriminant Function
    QDF_S = inv(Sigmapos) - inv(Sigmaneg)
    QDF_cT = muneg' * inv(Sigmaneg) - mupos' * inv(Sigmapos)  # 転置した状態で計算
    QDF_F = mupos' * inv(Sigmapos) * mupos - muneg' * inv(Sigmaneg) * muneg
            + log(det(Sigmapos) / det(Sigmaneg)) - 2 * log(Ppos / Pneg)

    rslt[:QDF_S], rslt[:QDF_ct], rslt[:QDF_F] = QDF_S, QDF_cT, QDF_F
    myprint(QDF_S, QDF_cT, QDF_F)

    # 2次識別関数の境界線計算
    numx, numy = 200, 100
    gridx = range(minimum(data[:pimatr].Glu), maximum(data[:pimatr].Glu), numx)
    gridy = range(minimum(data[:pimatr].BMI), maximum(data[:pimatr].BMI), numy)

    QDF_z = qdfmesh(gridx, gridy, QDF_S, QDF_cT, QDF_F, 0)
    rslt[:QDF_z] = QDF_z

    # 2次識別関数の境界線プロット
    contourGluBMI(data[:pimatr], (gridx, gridy, reshape(QDF_z, numy, numx)))

    println("Done")
end

function qdfmesh(xgrid, ygrid, S, cT, F, thres)
    numx, numy = length(xgrid), length(ygrid)
    x = vec(xgrid' .* ones(numy))
    y = vec(ones(numx)' .* ygrid)

    numz = numx * numy
    z = zeros(numz)

    for i in 1:numz
        z[i] = qdf(x[i], y[i], S, cT, F, thres)
    end

    return z
end

function qdf(x, y, S, cT, F, thres)
    X = [x, y]
    Y = X' * S * X + 2 * cT * X + F
    Y = Y > thres ? 1. : 0.
    return Y
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
