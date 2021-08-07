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

# ╔═╡ 5607810a-621b-4ed1-ac72-a4964621cfe5
JUtils.create_doc

# ╔═╡ 3bb08101-95c8-4dff-9516-67226c852392
md"""
# Utility
"""

# ╔═╡ 87ace88b-2fe6-4d01-8c01-f4b8a2c31384
function ground(args...)
	background("white")
	sethue("black")
end

# ╔═╡ a5488fc2-7c8d-4260-8769-3655a9dcd373
begin
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
			(args...)-> arrow(
				Point(-200, height_1), 
				Point(200,height_1)),
				linewidth=2.0
		)
	]

act!(arrows[1], Action(1:stops[1], appear(:scale)))
	
# ROUND 1 
bulb = Object(
		stops[1]:n_frames, 
		(args...)->lamp(O, 40, n_frames), 
		Point(-280, height_1 - 40)
	)

act!(bulb, Action(1:stops[1], appear(:fade)))
	
# ROUND 2 	
lens = Object(starts[3]:n_frames,
		(args...) -> draw_lens(
			pos=Point(0,height_1 - 75),
			size=20
		)
	)
	
lens = make_lens(pos=Point(0, height_1 - 70), size=40, frames=starts[3]:n_frames)

# ROUND 3
obs=[]
for i in 1:10
	r_p = random_point(400,400)
	ob = create_doc(point=r_p, sizex=100, sizey=110, frames=starts[5]:n_frames)
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

# ╔═╡ 975c3747-7922-4619-85c9-62bcb0a7a1fe
begin
max_frames = 2
	
# point=r_p, sizex=100, sizey=110, frames=starts[5]:n_frames
function doc(args...; pos=pos, sizex, sizey, frames=1:100)
	setline(2)
	line(pos - Point(sizex÷2, sizey÷2), pos - Point(-sizex÷2, sizey÷2), :stroke)
	line(pos - Point(sizex÷2, sizey÷2), pos - Point(sizex÷2, -sizey÷2), :stroke)
end

test_video = Video(300, 300)
Background(1:max_frames, ground)
Object(1:max_frames, 
		(args...)->doc(
			pos=O, sizex=100, sizey=110, frames=starts[5]:n_frames
		)
	)
render(test_video, pathname="test.gif")
end

# ╔═╡ 722ef533-832b-4abf-ac90-3a48d0f4ade3
# function moving_object(object; start_point, final_point, frames=1:100)
# 	act!(
# 		object, 
# 		Action(
# 			frames, 
# 			polyout(2), 
# 			anim_translate(start_point, final_point)
# 			)
# 	)
# 	object
# end

# ╔═╡ Cell order:
# ╠═e3a36f34-f16e-11eb-0480-43a3e559f803
# ╟─3d896c63-b553-49a6-a901-c34688fedeeb
# ╠═975c3747-7922-4619-85c9-62bcb0a7a1fe
# ╠═a5488fc2-7c8d-4260-8769-3655a9dcd373
# ╠═5607810a-621b-4ed1-ac72-a4964621cfe5
# ╟─3bb08101-95c8-4dff-9516-67226c852392
# ╠═87ace88b-2fe6-4d01-8c01-f4b8a2c31384
# ╠═722ef533-832b-4abf-ac90-3a48d0f4ade3
