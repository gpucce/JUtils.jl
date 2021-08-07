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

function moving_text(;
  start_point, final_point, frames=1:100,
  body="stdtxt", size=200, valign=:baseline,
  halign=:center, kwargs...
)

ob = Object(
  frames,
  (args...) -> draw_text(args...,
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
