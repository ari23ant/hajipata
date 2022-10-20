using PyPlot

data = Dict{Symbol, Any}()
data[:X0] = [ 1.76405235  0.40015721; 0.97873798  2.2408932 ; 1.86755799 -0.97727788; 0.95008842 -0.15135721;
             -0.10321885  0.4105985 ; 0.14404357  1.45427351; 0.76103773  0.12167502; 0.44386323  0.33367433;
              1.49407907 -0.20515826; 0.3130677  -0.85409574; -2.55298982  0.6536186 ; 0.8644362  -0.74216502;
              2.26975462 -1.45436567; 0.04575852 -0.18718385; 1.53277921  1.46935877; 0.15494743  0.37816252;
             -0.88778575 -1.98079647; -0.34791215  0.15634897; 1.23029068  1.20237985; -0.38732682 -0.30230275 ]
data[:X1] = [ 1.45144703 1.57998206; 0.79372981 4.9507754 ; 1.99034782 2.5619257 ; 1.24720464 3.77749036;
              0.88610215 2.78725972; 1.60453344 3.3869025 ; 1.98919486 1.81936782; 2.47181777 3.42833187;
              2.56651722 3.3024719 ; 1.86567791 2.63725883; 1.82753955 2.64044684; 1.68685372 1.2737174 ;
              2.67742614 2.59821906; 0.86980165 3.46278226; 1.59270164 3.0519454 ; 3.22909056 3.12898291;
              3.63940068 1.76517418; 2.90234164 2.31518991; 1.62920285 2.42115034; 2.18844747 3.05616534 ]
data[:y] = [ 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]

rslt = Dict{Symbol, Any}()

function process(data::Dict{Symbol, Any}, rslt::Dict{Symbol, Any})
    println(" ------- Main process ------- ")

    # 訓練データプロット
    #plottraindata(data[:X0], data[:X1])

    # 必要なデータをローカル変数に格納
    X = [data[:X0]; data[:X1]]  # 連結する
    y = data[:y]

    rslt[:X] = X

    # モデル初期化
    num_row, num_col = size(X)
    m = initSVMsoft(num_row, num_col)
    rslt[:m] = m

    # 最適化
    fit!(m, X, y)

    rslt[:m] = m

    # プロット
    plotmodel(data[:X0], data[:X1], m)

    # 訓練データの正答数
    num_ans = sum( y .== estimate(m, X) )
    myprint("The number of correct answers is " * string(num_ans) * ".")

    println(" -------     Done     ------- ")
end

mutable struct SVMsoft
    a::Vector
    w::Vector
    b::Float64
    C::Float64  # <- SVMsoftから追加
end

function initSVMsoft(num_a, num_w)
    a = [0 for i in 1:num_a]
    w = [0.0 for i in 1:num_w]
    b = 0.0
    C = 0.0  # <- SVMsoftから追加
    m = SVMsoft(a, w, b, C)
    return m
end

function fit!(m::SVMsoft, X, y; m_C=1.0)
    # ----- 初期値設定
    # ラグランジュ未定定数の初期値をゼロとする
    n, d = size(X)  # nがデータ数、dが次元数
    a = zeros(n)
    ay = 0.0
    yx = y .* X
    ayx = zeros(d)  # ayx = vec( sum(a .* y .* X, dims=1) ) でもよい
    indices = [i for i in 1:n]

    m.C = m_C  # <- SVMsoftから追加

    # ----- 最適化
    while true
        ydf = y .* (1 .- yx * ayx)  # yxはすでに転置されてる

        # --- インデックスiとjを選択
        #Iminus = (y .< 0) .| (a .> 0)
        Iminus = ( (a .> 0) .& (y .> 0) ) .| ( (a .< m.C) .& (y .< 0) )  # <- SVMsoftから変更
        i_idx = argmin(ydf[Iminus])
        i = indices[Iminus][i_idx]

        #Iplus = (y .> 0) .| (a .> 0)
        Iplus = ( (a .> 0) .& (y .< 0) ) .| ( (a .< m.C) .& (y .> 0) )  # <- SVMsoftから変更
        j_idx = argmax(ydf[Iplus])
        j = indices[Iplus][j_idx]

        # --- iとjが最適解なら次式を満たす
        if ydf[i] >= ydf[j]
            break
        end

        # --- aiとajを求める
        # 増加分
        ay2 = ay - a[i]*y[i] - a[j]*y[j]
        ayx2 = ayx - a[i]*y[i]*X[i, :] - a[j]*y[j]*X[j, :]

        # aiを計算
        ai = (1 - y[i]*y[j] + y[i]*(X[i, :] - X[j, :])' * (X[j, :]*ay2 - ayx2)) / sum((X[i, :] - X[j, :]) .^ 2)

        if ai < 0
            ai = 0.0

        elseif ai > m.C  # <- SVMsoftから追加
            ai = m.C

        end

        # ajを計算
        aj = y[j] * (-ai * y[i] - ay2)

        if aj < 0
            aj = 0.0
            ai = y[i] * (-aj * y[j] - ay2)  # aiを計算し直す

        elseif aj > m.C  # <- SVMsoftから追加
            aj = m.C
            ai = y[i] * (-aj * y[j] - ay2)  # aiを計算し直す

        end

        # --- ayとayxを更新
        ay += (ai - a[i]) * y[i] + (aj - a[j]) * y[j]
        ayx += (ai - a[i]) * y[i] * X[i, :] + (aj - a[j]) * y[j] * X[j, :]

        # --- a[i]とa[j]を更新
        # 更新前後で値に変化ないときは終了する
        if ai == a[i]
            break
        end

        # 更新
        a[i] = ai
        a[j] = aj

    end

    # --- SVMsoftのパラメタ計算
    # ラグランジュ未定定数
    m.a = a

    # サポートベクトルはa!=0
    idx = (a .!= 0.0)

    # 超平面
    m.w = vec( sum(a[idx] .* y[idx] .* X[idx, :], dims=1) )
    m.b = sum(y[idx] - X[idx, :] * m.w) / sum(idx)
end

function estimate(m::SVMsoft, X)
    val = m.w' * X + m.b

    if val < 0
        ret = -1
    elseif val > 0
        ret = 1
    else
        ret = 0
    end

    return ret
end

function estimate(m::SVMsoft, X::Matrix)
    n, _ = size(X)
    rets = Vector{Int}(undef, n)

    for i in 1:n
        rets[i] = estimate(m, X[i, :])
    end

    return rets
end

function plottraindata(X0, X1)
    fig, ax = subplots()
    ax.set_aspect("equal")
    ax.scatter(X0[:, 1], X0[:, 2], color="k", marker="+")
    ax.scatter(X1[:, 1], X1[:, 2], color="k", marker="*")
end

function plotmodel(X0, X1, m)
    fig, ax = subplots()
    ax.set_aspect("equal")

    # 訓練データ
    ax.scatter(X0[:, 1], X0[:, 2], color="k", marker="+")
    ax.scatter(X1[:, 1], X1[:, 2], color="k", marker="*")

    # 識別超平面
    f(m, x) = (-m.w[1] * x - m.b) / m.w[2]
    #x1, x2 = -0.2, 6
    x1, x2 = -2, 4  # <- SVMsoftから変更
    ax.plot([x1, x2], [f(m, x1), f(m, x2)], color="k")

    # サポートベクトル
    idx = (m.a .!= 0.0)
    X = [X0; X1]  # 連結する
    ax.scatter(X[idx, 1], X[idx, 2], s=200, color=(0,0,0,0), edgecolor="k", marker="o")
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
