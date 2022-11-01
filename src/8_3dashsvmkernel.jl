using PyPlot

data = Dict{Symbol, Any}()
data[:X0] = [ 1.76405235  0.40015721;  0.97873798  2.2408932 ;  1.86755799 -0.97727788;  0.95008842 -0.15135721;
             -0.10321885  0.4105985 ;  0.14404357  1.45427351;  0.76103773  0.12167502;  0.44386323  0.33367433;
              1.49407907 -0.20515826;  0.3130677  -0.85409574; -2.55298982  0.6536186 ;  0.8644362  -0.74216502;
              2.26975462 -1.45436567;  0.04575852 -0.18718385;  1.53277921  1.46935877;  0.15494743  0.37816252;
             -0.88778575 -1.98079647; -0.34791215  0.15634897;  1.23029068  1.20237985; -0.38732682 -0.30230275;
             -1.04855297 -1.42001794; -1.70627019  1.9507754 ; -0.50965218 -0.4380743 ; -1.25279536  0.77749036;
             -1.61389785 -0.21274028; -0.89546656  0.3869025 ; -0.51080514 -1.18063218; -0.02818223  0.42833187;
              0.06651722  0.3024719 ; -0.63432209 -0.36274117; -0.67246045 -0.35955316; -0.81314628 -1.7262826 ;
              0.17742614 -0.40178094; -1.63019835  0.46278226; -0.90729836  0.0519454 ;  0.72909056  0.12898291;
              1.13940068 -1.23482582;  0.40234164 -0.68481009; -0.87079715 -0.57884966; -0.31155253  0.05616534;
             -1.16514984  0.90082649;  0.46566244 -1.53624369;  1.48825219  1.89588918;  1.17877957 -0.17992484;
             -1.07075262  1.05445173; -0.40317695  1.22244507;  0.20827498  0.97663904;  0.3563664   0.70657317;
              0.01050002  1.78587049;  0.12691209  0.40198936;  1.8831507  -1.34775906; -1.270485    0.96939671;
             -1.17312341  1.94362119; -0.41361898 -0.74745481;  1.92294203  1.48051479;  1.86755896  0.90604466;
             -0.86122569  1.91006495; -0.26800337  0.8024564 ;  0.94725197 -0.15501009;  0.61407937  0.92220667;
              0.37642553 -1.09940079;  0.29823817  1.3263859 ; -0.69456786 -0.14963454; -0.43515355  1.84926373;
              0.67229476  0.40746184; -0.76991607  0.53924919; -0.67433266  0.03183056; -0.63584608  0.67643329;
              0.57659082 -0.20829876;  0.39600671 -1.09306151; -1.49125759  0.4393917 ;  0.1666735   0.63503144;
              2.38314477  0.94447949; -0.91282223  1.11701629; -1.31590741 -0.4615846 ; -0.06824161  1.71334272;
             -0.74475482 -0.82643854; -0.09845252 -0.66347829;  1.12663592 -1.07993151; -1.14746865 -0.43782004;
             -0.49803245  1.92953205;  0.94942081  0.08755124; -1.22543552  0.84436298; -1.00021535 -1.5447711 ;
              1.18802979  0.31694261;  0.92085882  0.31872765;  0.85683061 -0.65102559; -1.03424284  0.68159452;
             -0.80340966 -0.68954978; -0.4555325   0.01747916; -0.35399391 -1.37495129; -0.6436184  -2.22340315;
              0.62523145 -1.60205766; -1.10438334  0.05216508; -0.739563    1.5430146 ; -1.29285691  0.26705087;
             -0.03928282 -1.1680935 ;  0.52327666 -0.17154633;  0.77179055  0.82350415;  2.16323595  1.33652795 ]
data[:X1] = [ 2.13081816  2.76062082; 3.5996596   3.65526373; 3.14013153  1.38304396; 2.47567388  2.26196909;
              2.7799246   2.90184961; 3.41017891  3.31721822; 3.28632796  2.5335809 ; 1.55555374  2.58995031;
              2.48297959  3.37915174; 4.75930895  2.95774285; 1.544055    2.65401822; 2.03640403  3.48148147;
              0.95920299  3.06326199; 2.65650654  3.23218104; 1.90268393  2.76207827; 1.07593909  2.50668012;
              1.95713852  3.41605005; 1.34381757  3.7811981 ; 3.99448454  0.93001497; 2.92625873  3.67690804;
              1.86256297  2.60272819; 2.36711942  2.70220912; 2.19098703  1.32399619; 3.65233156  4.07961859;
              1.68663574  1.53357567; 3.02106488  2.42421203; 2.64195316  2.68067158; 3.19153875  3.69474914;
              1.77440262  1.61663604; 0.9170616   3.61037938; 1.31114074  2.49318365; 1.90368596  2.9474327 ;
              0.56372019  3.1887786 ; 3.02389102  3.08842209; 2.18911383  3.09740017; 2.89904635  0.22740724;
              4.45591231  3.39009332; 1.84759142  2.60904662; 2.99374178  2.88389606; 0.46931553  5.06449286;
              2.38945934  4.02017271; 1.80795015  4.53637705; 2.78634369  3.60884383; 1.45474663  4.21114529;
              3.18981816  4.30184623; 1.87191244  2.51897288; 4.8039167   1.93998418; 2.3640503   4.13689136;
              2.59772497  3.58295368; 2.10055097  3.37005589; 1.19347315  4.65813068; 2.38183595  2.3198218 ;
              3.16638308  2.53928021; 1.16574153  1.65328249; 3.19377315  2.84042656; 2.36629844  4.07774381;
              1.37317419  2.26932225; 2.11512019  3.09435159; 2.45782855  2.71311281; 2.4383736   2.89269472;
              1.78039561  2.18700701; 2.77451636  2.10908492; 1.34264474  2.68770775; 2.34233298  5.2567235 ;
              1.79529972  3.94326072; 3.24718833  1.81105504; 3.27325298  1.81611936; -0.15917224  3.60631952;
              0.74410942  3.45093446; 1.8159891   4.6595508 ; 3.5685094   2.5466142 ; 1.81216239  1.7859226 ;
              2.05907737  2.7196445 ; 2.13530646  3.15670386; 3.0785215   3.34965446; 1.73585608  1.56220853;
              3.86453185  2.31055082; 1.8477064   2.47881069; 0.65693045  2.522026  ; 2.02034419  3.6203583 ;
              3.19845715  3.00377089; 3.43184837  3.33996498; 2.48431789  3.16092817; 2.30934651  2.60515049;
              2.23226646  1.87198867; 2.78044171  2.00687639; 3.34163126  2.75054142; 2.54949498  3.49383678;
              3.14331447  1.42937659; 2.29309632  3.88017891; 0.80189418  3.38728048; 0.24443577  1.97749316;
              2.53863055  1.3432849 ; 1.51448926  1.52816499; 4.14813493  3.16422776; 3.06729028  2.7773249 ;
              2.14656825  1.38352581; 2.20816264  2.23850779; 3.35792392  4.14110187; 3.96657872  3.85255194;]
data[:y] = [ 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
             1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
             1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
             1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
             1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ]

rslt = Dict{Symbol, Any}()

function process(data::Dict{Symbol, Any}, rslt::Dict{Symbol, Any})
    println(" ------- Main process ------- ")

    # 訓練データプロット
    #plottraindata(data[:X0], data[:X1])

    # 必要なデータをローカル変数に格納
    X = [data[:X0]; data[:X1]]  # 連結する
    y = data[:y]

    rslt[:X] = X

    # ------- SVM kernel -------
    # モデル初期化
    num_row, num_col = size(X)
    m = initSVMkernel(num_row, num_col)

    # 最適化
    fit!(m, X, y, rslt)
    rslt[:m] = m

    # プロット
    plotmodel(data[:X0], data[:X1], m)

    # 訓練データの正答数
    num_ans = sum( y .== estimate(m, X) )
    myprint("The number of correct answers is " * string(num_ans) * ".")

    """
    # ------- SVM soft margin -------
    # モデル初期化
    num_row, num_col = size(X)
    m = initSVMsoft(num_row, num_col)

    # 最適化
    fit!(m, X, y)
    rslt[:m] = m

    # プロット
    plotmodel(data[:X0], data[:X1], m)

    # 訓練データの正答数
    num_ans = sum( y .== estimate(m, X) )
    myprint("The number of correct answers is " * string(num_ans) * ".")
    """

    println(" -------     Done     ------- ")
end

# --- RBFkernel
mutable struct RBFkernel
    sigma2::Float64
    X::Matrix{Float64}
    values_::Matrix{Float64}
end

function initRBFkernel(_X, _sigma)
    sigma2 = _sigma^2
    X = _X
    values_ = Matrix{Float64}(undef, length(X[:, 1]), length(X[:, 1]))
    m = RBFkernel(sigma2, X, values_)
    return m
end

function value(m::RBFkernel, i, j)
    ret = exp( -sum( (m.X[i, :] - m.X[j, :]).^2 )
                / 2*m.sigma2 )
    return ret
end

newaxis = [CartesianIndex()]
function eval(m::RBFkernel, Z, s)
    ret = exp.( -sum( (m.X[s, newaxis, :] .- Z[newaxis, :, :]) .^ 2, dims=3 )[:, :, 1]
                / 2*m.sigma2 )
    return ret
end

# --- SVMkernel
mutable struct SVMkernel
    a::Vector
    w::Vector
    b::Float64
    C::Float64  # <- SVMsoftから追加
    s::Float64  # <- SVMkernelから追加
    y::Vector  # <- SVMkernelから追加
    kernel::RBFkernel
end

function initSVMkernel(num_a, num_w)
    a = [0 for i in 1:num_a]
    w = [0.0 for i in 1:num_w]
    b = 0.0
    C = 0.0  # <- SVMsoftから追加
    s = 0.0  # <- SVMkernelから追加
    y = [0 for i in 1:num_a]
    kernel = initRBFkernel(zeros(num_a, num_w), 0.0)
    m = SVMkernel(a, w, b, C, s, y, kernel)
    return m
end

function estimate(m::SVMkernel, X)
    s = (m.a .!= 0.0)
    ret = sign.(m.b .+ eval(m.kernel, X, s)' * (m.a[s].*m.y[s]))
    return ret
end

function fit!(m::SVMkernel, X, y, rslt; m_C=1.0, k_sigma=1.0, max_iter=10000)
    # ----- 初期値設定
    # ラグランジュ未定定数の初期値をゼロとする
    n, d = size(X)  # nがデータ数、dが次元数
    a = zeros(n)
    ay = 0.0
    indices = [i for i in 1:n]

    m.C = m_C  # <- SVMsoftから追加
    kernel = initRBFkernel(X, k_sigma)

    # ----- 最適化
    #for ii in 1:1000  # pythonと40ぐらいまではaiは同じだが、1000ぐらいで計算誤差が出始める
    #    myprint(ii)   # ただし、最終的な結果は同じ様子
    for ii in 1:max_iter
        s = (a .!= 0.0)

        #ydf = y .* (1 .- yx * ayx)  # yxはすでに転置されてる
        # 計算都合で、(a[s].*y[s])' * eval(kernel, X, s)の順序を逆にした
        ydf = y .* (1 .- (y .* (eval(kernel, X, s)' * (a[s].*y[s]))))  # <- SVMkernelから変更

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
        kii = value(kernel, i, i)
        kij = value(kernel, i, j)
        kjj = value(kernel, j, j)

        s = (a .!= 0.0)
        s[i] = false
        s[j] = false

        kxi = vec(eval(kernel, X[i, newaxis, :], s))
        kxj = vec(eval(kernel, X[j, newaxis, :], s))

        # aiを計算
        ai = ( (1 - y[i]*y[j] +  y[i]*( (kij - kjj)*ay2 - sum((kxi-kxj)' * (a[s].*y[s])) ) )
                        / (kii + kjj - 2*kij) )
        #myprint(ai)
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

        # --- a[i]とa[j]を更新
        # 更新前後で値に変化ないときは終了する
        if ai == a[i]
            break
        end

        # 更新
        a[i] = ai
        a[j] = aj

    end

    # --- SVMkernelのパラメタ計算
    # ラグランジュ未定定数
    m.a = a

    # サポートベクトルはa!=0
    s = (a .!= 0.0)
    m.b = sum( y[s] - eval(kernel, X[s, :], s)' * (a[s].*y[s]) ) / sum(s) # <- SVMkernelから変更

    m.y = y
    m.kernel = kernel
end

function plotmodel(X0, X1, m::SVMkernel)
    fig, ax = subplots()
    ax.set_aspect("equal")

    # 訓練データ
    ax.scatter(X0[:, 1], X0[:, 2], color="k", marker="+")
    ax.scatter(X1[:, 1], X1[:, 2], color="k", marker="*")

    # 境界線
    X = [X0; X1]
    gridnum = 200
    gridx = range(minimum(X[:, 1]), maximum(X[:, 1]), gridnum)
    gridy = range(minimum(X[:, 2]), maximum(X[:, 2]), gridnum)
    z = mesh(gridx, gridy, m)

    ax.contour(gridx, gridy, reshape(z, gridnum, gridnum), levels=[0], colors="k")
end

function mesh(gridx::StepRangeLen, gridy::StepRangeLen, m::SVMkernel)
    numx, numy = length(gridx), length(gridy)
    x = vec(gridx' .* ones(numy))
    y = vec(ones(numx)' .* gridy)

    X = [x y]

    Z = estimate(m, X)
    return Z
end

# --------------- SVM soft margin ---------------

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
