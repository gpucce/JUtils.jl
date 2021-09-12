### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# ╔═╡ 43a2b752-e6d2-11eb-0dbb-059487ed50e4
begin
using Pkg
Pkg.activate("..")
using PlutoUI, Colors,Javis, Animations, StatsBase, Fontconfig
import Luxor 
end

# ╔═╡ 21ed956a-2b0e-435a-977d-202ed102d2d0
begin
red = colorant"#ea5153"
blue = colorant"#212c52"
# grey = colorant"#323232"
grey = colorant"#7a8097"

n_frames = 200
left_margin = -230
right_margin = 230
top_margin = -125
bottom_margin = 125
step_len = Int(n_frames/5)
right_end = right_margin + 50
bottom_end = bottom_margin + 50
global_margin = 15
sizeof4 = 150
sizeofletters = 200
	
function ground(args...)
    background("white")
    sethue("black")
end
	
function convex_hull(p1, p2, p3, frame, n_frames, idx)
	
	if frame < idx * step_len
		x1, x2 = p1[1], p2[1]
		y1, y2 = p1[2], p2[2]
	 	Point(
			x1 * (1 - frame%step_len/step_len) + x2 * (frame%step_len/step_len),
			y1 * (1 - frame%step_len/step_len) + y2 * (frame%step_len/step_len)
		)
	else
		x1, x2 = p2[1], p3[1]
		y1, y2 = p2[2], p3[2]
	 	Point(
			# x1 * (1 - frame%step_len/step_len) + x2 * (frame%step_len/step_len),
			x1 * (1 - (frame-idx*step_len)/n_frames) + x2 * ((frame- idx*step_len)/n_frames),
			# y1 * (1 - frame%step_len/step_len) + y2 * (frame%step_len/step_len),
			y1 * (1 - (frame-idx*step_len)/n_frames) + y2 * ((frame- idx*step_len)/n_frames)
		)
	end
end
	
function from_to_end(idx, step_len)
	return ((idx - 1) * step_len) + 1 : n_frames
end

	
function gen_text(
			args...; size, body, x=0, y=0, 
			color=red,valign=:middle, halign=:left
		)
		
	fontface("Barlow")
	fontsize(size)
	setfont("Barlow", size)
	sethue(color)
	# settext(body, Point(x, y); valign=string(valign), halign=string(halign))
	text(body, Point(x, y); valign=valign, halign=halign)
end

	
my_video = Video(2 * right_end, 2 * bottom_end)
	
Background(1:n_frames, ground)
	
converter = [1,2,3,4]
	
letters = ["B", "4", "D", "S"]
locations = [
		left_margin - 16 + global_margin, 
		left_margin - 16 + global_margin + (sizeofletters ÷ 5) * 3 + global_margin,
		(right_margin - left_margin)/4 - global_margin,
		right_margin - global_margin
	]
letters = map(zip(1:4, letters, locations)) do (idx,letter, loc) 
		
	Object(from_to_end(converter[idx], step_len), 
			(args...)->gen_text(args..., 
				size = size = letter != "4" ? sizeofletters : sizeof4,
				body = letter, 
				x = loc,
				y = letter != "4" ? 
				  top_margin + global_margin : 
				  top_margin + sizeofletters - sizeof4,
				
				color = (letter != "4" ? blue : red),
				halign = idx <= 2 ? :left : :right,
				valign = :top
				)
		)
	end


map(enumerate(letters)) do (idx,l)
	act!(l, Action(0:step_len, linear(), appear(:fade)))
end
	
words = ["Business", "Engineering", "Data", "Science"]
words = map(enumerate(words)) do (idx, word)
	ob1 = Object(from_to_end(converter[idx],step_len),
			(args...)->gen_text(args..., 
				size=45, 
				body=word, 
				x = if idx == 1 
					left_margin - 3 + global_margin
				elseif idx == 3
					left_margin + 150
				else
					right_margin - global_margin
				end,
				y = idx <= 2 ? bottom_margin - 70 : bottom_margin - global_margin,
				color = idx != 2 ? red : blue,
				halign = idx%2 == 1 ? :left : :right,
				valign = idx <= 2 ? :middle : :bottom
				), 
			keep=true
	)
	if idx == 2
		ob2 = Object(from_to_end(converter[idx],step_len),
			(args...)->gen_text(args..., 
				size=50, 
				body="for", 
				x = left_margin + global_margin,
				y = bottom_margin - global_margin,
				color = blue,
				halign = :left,
				valign = :bottom
				), 
			keep=true
	)
		[ob1, ob2]
	else
		ob1
	end
end

map(enumerate(words)) do (idx,w)
	act!(w, Action(0:step_len, linear(), appear(:fade)))
end

	
map(1:4) do idx
	if idx == 1
		p1 = Point(left_margin, bottom_margin)
		p2 = Point(left_margin, top_margin)
		p3 = Point(left_margin, -bottom_end)
	elseif idx == 2
		p1 = Point(left_margin, top_margin)
	    p2 = Point(right_margin, top_margin)
		p3 = Point(right_end, top_margin)
	elseif idx == 3
		p1 = Point(right_margin, top_margin)
	    p2 = Point(right_margin, bottom_margin)
		p3 = Point(right_margin, bottom_end)
	elseif idx == 4
		p1 = Point(right_margin, bottom_margin)
	    p2 = Point(left_margin, bottom_margin)
		p3 = Point(-right_end, bottom_margin)
	end
	Object(
			from_to_end(converter[idx], step_len), 
			(args...) -> line(
				p1,
				convex_hull(p1, p2, p3, args[3], step_len, idx), 
				:stroke), keep=true)	
end
	
render(
		my_video,
		pathname = "../output/B4DS.gif"
		
	)
end

# ╔═╡ baafcd46-e0a7-40a1-84d2-d51b82669794
let
function ground(args...) 
    background("white") # canvas background
    sethue("black") # pen color
end
	
function object(p=O, color="black")
    sethue(color)
    circle(p, 25, :fill)
    return p
end
	
function path!(points, pos, color)
    sethue(color)
    push!(points, pos) # add pos to points
    circle.(points, 2, :fill) # draws a circle for each point using broadcasting
end
	
function connector(p1, p2, color)
    sethue(color)
    line(p1,p2, :stroke)
end
	
myvideo = Video(500, 500)
path_of_red = []
Background(1:70, ground)
red_ball = Object(1:70, (args...) -> object(O, "red"), Point(100, 0))
act!(red_ball, Action(anim_rotate_around(2π, O)))
Object(1:70, (args...)->path!(path_of_red, pos(red_ball), "red"))
path_of_blue = []
blue_ball = Object(1:70, (args...) -> object(O, "blue"), Point(200,80))
act!(blue_ball, Action(anim_rotate_around(2π, 0.0, red_ball)))
Object(1:70, (args...)->path!(path_of_blue, pos(blue_ball), "blue"))
Object(1:70, (args...)->connector(pos(red_ball), pos(blue_ball), "black"))
	
render(
    myvideo;
    pathname="../output/circle.gif"
)
end

# ╔═╡ d2e53571-5e30-4979-a1a6-39c33c98481a
md"## Utility"

# ╔═╡ e1f05461-f356-4f09-a02f-7a864acc3361
function egg(radius, action=:none)
    A, B = [Point(x, 0) for x in [-radius, radius]]
    nints, C, D =
        intersectionlinecircle(Point(0, -2radius), Point(0, 2radius), A, 2radius)

    flag, C1 = intersectionlinecircle(C, D, O, radius)
    nints, I3, I4 = intersectionlinecircle(A, C1, A, 2radius)
    nints, I1, I2 = intersectionlinecircle(B, C1, B, 2radius)

    if distance(C1, I1) < distance(C1, I2)
        ip1 = I1
    else
        ip1 = I2
    end
    if distance(C1, I3) < distance(C1, I4)
        ip2 = I3
    else
        ip2 = I4
    end

    newpath()
    arc2r(B, A, ip1, :path)
    arc2r(C1, ip1, ip2, :path)
    arc2r(A, ip2, B, :path)
    arc2r(O, B, A, :path)
    closepath()

    do_action(action)
end

# ╔═╡ Cell order:
# ╟─baafcd46-e0a7-40a1-84d2-d51b82669794
# ╟─21ed956a-2b0e-435a-977d-202ed102d2d0
# ╟─d2e53571-5e30-4979-a1a6-39c33c98481a
# ╟─43a2b752-e6d2-11eb-0dbb-059487ed50e4
# ╟─e1f05461-f356-4f09-a02f-7a864acc3361
