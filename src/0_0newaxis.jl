
myprint(args...) = (for arg in args myshow(arg) end)
myshow(arg::String) = println(arg)
myshow(arg) = (show(stdout, "text/plain", arg); println())

X = [1 2;
     2 3;
     3 4;
     4 5;
     5 6;
     6 7;
     7 9]

labels = [true, false, true, false, true, false, true]

newaxis = [CartesianIndex()]

myprint(X)
myprint(labels)

println("----------------------")

myprint(X[:, newaxis, :])
myprint(size(X[:, newaxis, :]))
myprint(X[labels, newaxis, :])

println("----------------------")

myprint(X[newaxis, :, :])
myprint(size(X[newaxis, :, :]))

println("----------------------")

myprint(X[labels, newaxis, :] .- X[newaxis, :, :])
println("----------------------")
myprint((X[labels, newaxis, :] .- X[newaxis, :, :]) .^2)
println("----------------------")
myprint(sum( (X[labels, newaxis, :] .- X[newaxis, :, :]) .^2, dims=3 ))
myprint(sum( (X[labels, newaxis, :] .- X[newaxis, :, :]) .^2, dims=3 )[:, :, 1])
println("----------------------")
#myprint(exp.(sum( (X[labels, newaxis, :] .- X[newaxis, :, :]) .^2, dims=3 )))
println("----------------------")
myprint(vec( sum( (X[labels, newaxis, :] .- X[newaxis, :, :]) .^2, dims=3 )))


println("======================")

#myprint(X[:, :, newaxis])
#myprint(size(X[:, :, newaxis]))
#myprint(X[labels, :, newaxis])
#
#println("----------------------")
#
##myprint(X[:, newaxis, :])
#myprint(X[newaxis, :, :])
#myprint(size(X[newaxis, :, :]))
#
#println("----------------------")
#
#myprint(X[labels, :, newaxis] .- X[newaxis, :, :])
#
