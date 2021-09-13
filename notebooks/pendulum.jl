### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# ╔═╡ 8ff88bf0-14cb-11ec-2f1c-8f7745e8a6b2
begin
using Pkg
Pkg.activate("..")
using Javis, JUtils, Animations, PlutoUI, Plots
end

# ╔═╡ b3c04a1d-41d3-458f-8624-3cb6c114f210
function ground(args...)
	background("black")
	sethue("white")
end

# ╔═╡ 42d0c661-344f-4358-869d-cf5929056392
begin
n_frames = 500
pendulum_video = Video(800, 800)
Background(1:n_frames, ground)

shift = Point(0, 0)
basepoint = shift + O
	
Object(JCircle(basepoint, 300, action=:stroke, color="white"))
	
motion(t) = 0.5 * ℯ^(-3*(t)/2) * cos(10t)
	
coords = map(1:n_frames) do i
	 shift + 300 * Point(sin(motion(i/n_frames)), cos(motion(i/n_frames)))
end
	
	
	
points = map(enumerate(coords)) do (idx, p)
	Object(idx:idx, JLine(basepoint, shift + p, color="white", linewidth=3))
	Object(idx:idx, JCircle(shift + p, 30,action=:fill, color="red"))
end

Object(1:n_frames, JCircle(basepoint, 10, action=:fill, color="blue"))
	
v = render(pendulum_video, pathname="../output/pendulum.gif")
end

# ╔═╡ e4d49656-5ebb-4b51-b6cc-b2a5209a904b
plot(0:0.01:2, motion.(0:0.01:2))

# ╔═╡ Cell order:
# ╟─8ff88bf0-14cb-11ec-2f1c-8f7745e8a6b2
# ╟─b3c04a1d-41d3-458f-8624-3cb6c114f210
# ╟─42d0c661-344f-4358-869d-cf5929056392
# ╟─e4d49656-5ebb-4b51-b6cc-b2a5209a904b
