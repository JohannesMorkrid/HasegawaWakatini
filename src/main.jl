##
include("Operators.jl")
using .Operators
include("Timestepper.jl")
using .Timestepper
using FFTW
using Plots

##
using DifferentialEquations
using HDF5

# Read in input file
for line in readlines("input.txt")
    if line != ""
        if first(line) != "#"
            println(line)
        end
    end
end

a = fftfreq(64)
f = n0
contour(x, y, real(f))

df = [1000 * f[j, k] * (a[j]^2 + a[k]^2) for j in eachindex(a), k in eachindex(a)]
#df = [1 for j in eachindex(x), k in eachindex(y)]

f = f + df * 3

t = real(ifft(f))

plot(x, y, t)
plot(x, y, real(ifft(n0)))
plot(x, y, real(ifft(f)))

function gaussianField(x, y, sx=1, sy=1)
    1 / (2 * π * sqrt(sx * sy)) * exp(-(x .^ 2 / sx + y .^ 2 / sy) / 2)
end

## Gaussian example
D = 1000000.0
N = 64

x = LinRange(-4, 4, N);
y = x;
a = fftfreq(N)

n0 = fft(gaussianField.(x, y', 1, 1))
tspan = (0.0, 200.0)
#problem = ODEProblem(Laplacian!, n0, tspan)
#sol = solve(problem)

#println(size(sol))

#contourf(x, y, real(ifft(sol[:, :, 9])))
#contourf(x, y, real(ifft(n0)))

for i in 1:10000
    n0 = timeStep(n0, a, 0, 0.01, Laplacian)
    if i%100 == 1
        display(surface(x,y,real(ifft(n0)),zlims=(0,0.2)))
    end
end