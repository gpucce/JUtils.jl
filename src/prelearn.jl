function make_prelearn(; n_frames, height, width, margin)
	marg_width = width ÷ 2 - margin
	marg_height = height ÷ 2 - margin
	xpos = range(-marg_width, marg_width, length = 3)
	ypos = range(-marg_height, marg_height, length = 5)
	dist = Normal(0, 50)
	
	circ_start_points = Point.(xpos[1], ypos)
	circ_middle_points = [Point(rand(dist), rand(dist)) for i in circ_start_points]
	middle_shifts = circ_middle_points .- circ_start_points
	circ_final_points = [
		Point(rand(xpos[3] - 2margin:xpos[3]), ypos[i]) for i in 1:length(circ_start_points)
		]
	final_shifts = circ_final_points .- circ_middle_points
	
	time_steps = floor.(Int, range(1, n_frames, length=6))
	
	start_lines = [Object(time_steps[1]:time_steps[6], JLine(point + Point(10, 0), point + Point(marg_width/3, 0))) for point in circ_start_points]
	middle_lines = [
		Object(
			time_steps[3]:time_steps[6], 
			JLine(p1, p2)
			) 
		for (p1, p2) in Base.product(circ_middle_points, circ_middle_points) 
		if p1 != p2
		]
	final_lines = [Object(time_steps[5]:time_steps[6], @JShape begin
				arrow(circ_final_points[i], circ_final_points[i+1])
			end) for i in 1:length(circ_final_points)-1]
	
	points = [Object(time_steps[1]:time_steps[2], JCircle(point, 5, action=:fill)) for point in circ_start_points]
	final_points = [
		Object(time_steps[2]:time_steps[6], JCircle(point, 5, action=:fill, color=randomhue())) for point in circ_start_points
		]
	
	
	for (idx, point) in enumerate(final_points)
		act!(
			point, 
			Action(time_steps[1]:time_steps[2], anim_translate(middle_shifts[idx]))
		)
		act!(
			point,
			Action(time_steps[3]:time_steps[4], anim_translate(final_shifts[idx]))
		)
	end
	final_points
end