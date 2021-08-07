module JUtils

using Colors
using Animations
using Javis
using Random
using FileIO

include("Objects.jl")

export load_and_scale, thickbox, create_doc
export moving_object, random_point
export gen_text, make_text, moving_text
export continuous_lines!
export lamp, make_lamp, lens, make_lens

function load_and_scale(;pos)
	scale(0.15)
	placeimage(load("bulb.png"), pos, centered=true)
end

function lens(;pos, size)
	setline(4)
	line(pos, pos+Point(40,40), :stroke)
	sethue(colorant"lightskyblue2")
	circle(pos, size, :fill)
	sethue(colorant"black")
	circle(pos, size, :stroke)
end

function thickbox(;point, sizex, sizey, scaler)
	scale(1)

	half_x = sizex÷2
	half_y = sizey÷2

	setline(4)
	line(point-Point(half_x,half_y), point-Point(half_x,-half_y))
	line(point+Point(half_x,half_y), point+Point(half_x,-half_y))
	line(point-Point(half_x,half_y), point+Point(half_x,-half_y))

	move(point+Point(-half_x,half_y))
	curve(
		point+Point(-half_x÷2,+half_y-half_y÷2),
		point+Point(half_x÷2, half_y+half_y÷2),
		point+Point(half_x,half_y)
	)
	strokepath()

	for i in 1:4
		setline(2)
		locp = point - Point(0, sizey ÷ 2) +  Point(0, i*sizey/5)
		line(
				locp-Point((sizex ÷ 2 - 10),0),
				locp+Point(sizex ÷ 2 - 10,0),
				:stroke
		)
	end

end



function moving_object(object; start_point, final_point, frames=1:100)
	act!(
		object,
		Action(
			frames,
			polyout(2),
			anim_translate(start_point, final_point)
			)
	)
	object
end


function random_point(width, height)
  Point(
    Random.rand(-width:width),
    Random.rand(-height:height)
  )
end

function gen_text(
		args...;
		body="stdtxt",
		size=200,
		pos=O,
		valign=:center,
		halign=:baseline,
		kwargs...
	)

	fontsize(size)
	text(body, pos, valign=valign, halign=halign)
end



function moving_text(;
		start_point, final_point, frames=1:100,
		body="stdtxt", size=200, valign=:baseline,
		halign=:center, kwargs...
	)

	ob = Object(
		frames,
		(args...) -> gen_text(args...,
			body=body,
			size=size,
			pos=start_point,
			valign=valign,
			halign=halign,
		)
	)

	act!(ob, Action(1:length(frames), polyout(2), anim_translate(start_point, final_point)))
	ob
end

function continuous_lines!(path, p, color)
	sethue(color)
	push!(path, p)
	map(enumerate(path)) do (idx, p)
		if idx > 1
			line(path[idx-1], p, :stroke)
		end
	end
end

function lamp(pos, r, max_frames; show_drawing=false)

	setline(2)
	circ = (pos, r)

	if show_drawing
		c1 = Object(1:max_frames, (args...)->circle(circ..., :stroke))
		act!(c1, Action(1:max_frames ÷ 2, disappear(:fade)))
	end

	box_size = r ÷ 2
	topleft = pos + Point(-box_size, 3box_size)
	bottomright = pos + Point(box_size, 5box_size)
	shift = Point(0, r÷5)
	box(topleft + shift, bottomright - shift, :fill)

	arc1_points = let
		_, pt1, pt2 = circlepointtangent(topleft, r, circ...)
		_, p1, p2 = intersectioncirclecircle(pos, r, pt2, r)
		pt2, p2, topleft
	end
	arc2r(arc1_points..., :stroke)
	if show_drawing
		c2 = Object(1:max_frames, (args...)->circle(arc1_points[1], r, :stroke))
		act!(c2, Action(1:max_frames ÷ 2, disappear(:fade)))
	end

	arc2_points = let
		_, pt1, pt2 = circlepointtangent(topleft + Point(2box_size, 0), r, circ...)
		_, p1, p2 = intersectioncirclecircle(pos, r, pt1, r)
		pt1, topleft + Point(2box_size, 0), p2
	end
	arc2r(arc2_points..., :stroke)

	if show_drawing
		c3 = Object(1:max_frames, (args...)->circle(arc2_points[1], r, :stroke))
		act!(c3, Action(1:max_frames ÷ 2, disappear(:fade)))
	end

	arc2r(pos, arc1_points[2], arc2_points[3], :stroke)
	line(topleft, topleft+Point(2box_size,0), :stroke)

	box(bottomright - shift - Point(box_size, 0), box_size/1.5, box_size÷2, :fill)


	setline(1)
	minishift = Point(box_size÷3, 0)
	megashift = Point(box_size/1.5, 0)
	line(Point(pos.x, pos.y + 3box_size) + minishift, pos + Point(0, box_size÷2) + megashift, :stroke)
	line(Point(pos.x, pos.y + 3box_size) - minishift, pos + Point(0, box_size÷2) - megashift, :stroke)

	path_start = pos + Point(0, box_size÷2) - megashift
	path_end = pos + Point(0, box_size÷2) + megashift
	move(path_start)
	curve(path_start - Point(0, r÷2), path_end + Point(0,r÷2), path_end)
	strokepath()

	adjust = r÷4
	n_lines = 6
	line(pos - Point(0, r + adjust), pos - Point(0, 2r-adjust), :stroke)
	for i in 1:n_lines
		rotate(π/(1.5*n_lines))
		line(pos - Point(0, r + adjust), pos - Point(0, 2r-adjust), :stroke)
	end
	rotate(-(n_lines * π)/(1.5*n_lines))
	for i in 1:n_lines
		rotate(-π/(1.5*n_lines))
		line(pos - Point(0, r + adjust), pos - Point(0, 2r-adjust), :stroke)
	end
end

end
