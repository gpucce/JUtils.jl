function load_and_scale(;pos)
	scale(0.15)
	placeimage(load("bulb.png"), pos, centered=true)
end

function draw_lens(;pos, size)
	setline(4)
	line(pos, pos + Point(2*size, 2*size), :stroke)
	sethue(colorant"lightskyblue2")
	circle(pos, size, :fill)
	sethue(colorant"black")
	circle(pos, size, :stroke)
end

function draw_thickbox(;point, sizex, sizey, scaler)
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
	# strokepath()

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

function draw_random_point(width, height)
  Point(
    Random.rand(-width:width),
    Random.rand(-height:height)
  )
end

function draw_text(
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

function draw_continuous_lines!(path, p, color)
	sethue(color)
	push!(path, p)
	map(enumerate(path)) do (idx, p)
		if idx > 1
			line(path[idx-1], p, :stroke)
		end
	end
end

function draw_lamp(pos, r, max_frames; show_drawing=false)

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

function draw_doc(args...; pos=pos, sizex, sizey, rng=42)

	setline(2)
	topleft = pos - Point(sizex÷2, sizey÷2)
	topright = pos - Point(-sizex÷2, sizey÷2)
	bottomleft = pos - Point(sizex÷2, -sizey÷2)
	bottomright = pos - Point(-sizex÷2, -sizey÷2)
	line(topleft, topright, :stroke)
	line(topleft, bottomleft, :stroke)
	line(topright, bottomright, :stoke)

  strokepath()

	move(bottomleft)
	curve(
			bottomleft - Point(-sizex÷4, sizey÷3),
			bottomright + Point(-sizex÷4, sizey÷3),
			bottomright
		)
	plist = pathtopoly()
	strokepath()

	setline(1)
	n_lines = 4
	margin = sizex÷8
	for i in 1:n_lines
    if i == 1
      Random.seed!(rng)
      ypos = topleft.y + i*sizey÷n_lines
      n_dots = 20
      points = [Point(pos.x - sizex÷2 + 2*sizex÷n_dots, ypos + rand(-8:8))]

      for i in 2:n_dots-2
        new_p = Point(pos.x - sizex÷2 + i*sizex÷n_dots, ypos + rand(-8:8))
        push!(points, new_p)
        line(new_p, points[i-1], :stroke)
      end
    elseif i == 2
      fontsize(sizey÷6)
      Random.seed!(rng)
      text(
        "|" * join(map(x->string(rand(1:9)),1:5), ",") * "|",
        Point(pos.x, topleft.y + i*sizey÷n_lines), valign=:middle, halign=:center
        )
    elseif i == 3
      fontface("Barlow")
      fontsize(sizey÷9)
      text(
        "Natural Language",
        Point(pos.x, topleft.y + i*sizey÷n_lines), valign=:middle, halign=:center
        )
		elseif i < n_lines
			line(
				topleft + Point(margin, i*sizey÷n_lines),
				topright + Point(-margin, i*sizey÷n_lines),
				:stroke
			)
		else
			line(
        topleft + Point(margin, i*sizey÷n_lines - 0.2sizey÷n_lines) + Point(sizex÷2, 0),
				topright + Point(-margin, i*sizey÷n_lines - 0.2sizey÷n_lines),
				:stroke
			)
		end
	end
end

function draw_banner(
  args...;
  pos, sizex, sizey, words=["SOME", "WORDS"], rng=Random.GLOBAL_RNG
)

  setline(2)
  box(pos, sizex, sizey, :stroke)
  topleft = pos - Point(sizex÷2, sizey÷2)
  topright = pos - Point(-sizex÷2, sizey÷2)
  banner_xsize = topright.x - topleft.x

  Random.seed!(rng)
  n_words = length(words)
  post_it_size = sizex ÷ (1 + maximum(length.(words)))
  letters_colors = range(HSV(0,10,1), stop=HSV(-360,10,1), length=20)
  for (idx, word) in enumerate(words)
    word_length = length(word)
    for i in 1:word_length
      letter = string(word[i])
      postit_step = word_length ÷ 2 + 1
      even_shift = (1 - (word_length % 2)) * (post_it_size / 2)
      xpos = pos.x + (i - postit_step) * post_it_size + even_shift
      ypos = topleft.y + idx * sizey ÷ (1 + n_words)

      postit_p = Point(xpos, ypos)
      box(postit_p, post_it_size, post_it_size, :stroke)
      fontsize(post_it_size)
      sethue(rand(letters_colors))
      text(letter, postit_p, valign=:middle, halign=:center)
      sethue("black")
    end
  end
end


function draw_roc(pos, tar, nontar, p; c1=colorant"red", c2=colorant"blue", size=300, margin=10)
	myroc = roc(tar, nontar)

	sens = sensitivity(tar, nontar, p)
	spec = specificity(tar, nontar, p)

	@layer begin
	    Luxor.setline(2)
	    rocpoints = Point.(myroc.pmiss .* size, (myroc.pfa) .* size)
	    Javis.translate(-midpoint(rocpoints[1], rocpoints[end]) + pos)
	    
	    sethue(c1)
	    first_half = rocpoints[myroc.pmiss .<= sens]
	    second_half = rocpoints[myroc.pmiss .>= sens]
	    poly([first_half; second_half[1]], :stroke)
	    
	    sethue(c2)
	    poly(second_half, :stroke)
	    sethue("black")
	    
	    Luxor.setline(1)
	    line(rocpoints[1], rocpoints[end], :stroke)
	    
	    tickline(
	    	rocpoints[1] + (0, margin), 
	    	Point(rocpoints[end].x, rocpoints[1].y) + (0, margin)
	    )
	    tickline(
	    	Point(rocpoints[1].x, rocpoints[end].y) + (-margin, 0),
	    	rocpoints[1] + (-margin, 0),
	    	startnumber=1,
	    	finishnumber=0
	    )
	    
	    Luxor.setline(10)
	    sethue(c1)
	    sensx = rocpoints[1].x - margin - size / 3
	    line(
	    	Point(sensx, rocpoints[1].y),
	    	Point(sensx, first_half[end].y),
	    	:stroke
	    )
	    Luxor.fontsize(20)
	    label("Sensitivity", :S, Point(sensx, rocpoints[1].y), offset=10)
	    
	    sethue(c2)
		specx = sensx - size / 3
	    line(
	    	Point(specx, rocpoints[1].y),
	    	Point(specx, rocpoints[1].y + (first_half[end].x - second_half[end].x)),
	    	:stroke
	    )
    
	    # Luxor.fontsize(20)
	    label("Specificity", :S, Point(specx, rocpoints[1].y), offset=10)
	end
end