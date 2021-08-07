### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ e3a36f34-f16e-11eb-0480-43a3e559f803
begin
using Pkg
Pkg.activate(".")
using Revise, Javis, Animations, PlutoUI, Random, Colors, FileIO, JUtils
import Luxor
end

# ╔═╡ 3d896c63-b553-49a6-a901-c34688fedeeb
md"""
# Test Video
"""

# ╔═╡ 3bb08101-95c8-4dff-9516-67226c852392
md"""
# Utility
"""

# ╔═╡ 87ace88b-2fe6-4d01-8c01-f4b8a2c31384
function ground(args...)
	background("white")
	sethue("black")
end

# ╔═╡ 975c3747-7922-4619-85c9-62bcb0a7a1fe
let
max_frames = 2

test_video = Video(300, 300)
Background(1:max_frames, ground)
Object(1:max_frames, 
		(args...)->draw_doc(
			pos=O, sizex=110, sizey=110
		)
	)
render(test_video, pathname="test.gif")
end

# ╔═╡ a5488fc2-7c8d-4260-8769-3655a9dcd373
let
n_frames = 400
n_parts = 6
height_text = -250
height_1 = -100
video = Video(800, 600)
starts = [1; [n_frames÷n_parts * i for i in 1:n_parts-1]]
stops = [n_frames÷n_parts * i for i in 1:n_parts]


	
bg = Background(1:n_frames, ground)

	
# ALL TEXTS
texts = [
	make_text(body="Have an Idea", text_frames=starts[1]:stops[2], action_frames=1:stops[2]-stops[1]÷3, size=50, pos=Point(0, height_text), halign=:center),
	make_text(body="Gather Data", text_frames=starts[4]:stops[6], action_frames=1:stops[1]-stops[1]÷3, size=50, pos=Point(0, height_text), halign=:center)
	]
	
# ALL ARROWS
arrows = [
		Object(
			starts[3]:n_frames, 
			(args...) -> arrow(
				Point(-150, height_1), 
				Point(150, height_1)),
				linewidth=5
		)
	]

act!(arrows[1], Action(1:stops[1], appear(:scale)))
	
# ROUND 1 
bulb = Object(
		stops[1]:n_frames, 
		(args...)->draw_lamp(O, 40, n_frames), 
		Point(-280, height_1 - 40)
	)

act!(bulb, Action(1:stops[1], appear(:fade)))
	
# ROUND 2 	
lens = make_lens(pos=Point(0, height_1 - 70), size=20, frames=starts[3]:n_frames)

# ROUND 3
obs=[]
for i in 1:10
	r_p = draw_random_point(100,200)
	ob = make_doc(pos=r_p, sizex=100, sizey=110, frames=starts[5]:n_frames)
	push!(obs,ob)
	moving_object(ob, start_point=r_p, 
		final_point=Point(300,height_1), 
		frames=1:stops[1]
	)
end
	
render(
		video,
		pathname="resprint.gif"	
	)
end

# ╔═╡ Cell order:
# ╠═e3a36f34-f16e-11eb-0480-43a3e559f803
# ╟─3d896c63-b553-49a6-a901-c34688fedeeb
# ╟─975c3747-7922-4619-85c9-62bcb0a7a1fe
# ╟─a5488fc2-7c8d-4260-8769-3655a9dcd373
# ╟─3bb08101-95c8-4dff-9516-67226c852392
# ╠═87ace88b-2fe6-4d01-8c01-f4b8a2c31384
