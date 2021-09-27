### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 8ff88bf0-14cb-11ec-2f1c-8f7745e8a6b2
begin
    using Pkg
    Pkg.activate("..")
    using Revise, Javis, JUtils, LaTeXStrings
end

# ╔═╡ b3c04a1d-41d3-458f-8624-3cb6c114f210
function ground(args...)
    background("black")
    sethue("white")
end

# ╔═╡ 7ac8f5b3-fa39-4e15-841b-5093437afbce
L"\huge{\theta(t) = \pi e^{-\frac{t}{\tau}} \cos(t\omega)}"

# ╔═╡ 4bd25c64-0913-4720-81d9-bd197def92ed
begin
    pendulum_video = Video(800, 800)
    Background(1:500, ground)
    JUtils.pendulum(first_frame = 1, last_frame = 500)
    v = render(pendulum_video, pathname = "../output/pendulum.gif", framerate = 30)
end

# ╔═╡ Cell order:
# ╠═8ff88bf0-14cb-11ec-2f1c-8f7745e8a6b2
# ╠═b3c04a1d-41d3-458f-8624-3cb6c114f210
# ╠═7ac8f5b3-fa39-4e15-841b-5093437afbce
# ╠═4bd25c64-0913-4720-81d9-bd197def92ed
