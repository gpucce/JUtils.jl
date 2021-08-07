function make_doc(args...; point, sizex=10, sizey=10, frames=1:100)
	ob = Object(
		frames,
		(args...) -> thickbox(
			point=point,
			sizex=sizex,
			sizey=sizey,
			scaler=10)
		)
	ob
end

function make_text(args...;
  body="stdtxt",
  size=200,
  pos=O,
  text_frames=1:100,
  action_frames=1:100,
  valign=:center,
  halign=:baseline,
  kwargs...
)
ob = Object(
  text_frames,
  (args...) -> gen_text(
    body=body,
    size=size,
    pos=pos,
    valign=valign,
    halign=halign
    ),
)
act!(
  ob,
  Action(
    action_frames,
    appear(:draw_text)
    )
)
ob
end

function make_lamp(args...; pos, r, frames=1:100, show_drawing=false)
  ob = Object(
    frames,
    (args...) -> lamp(pos - r, r, max_frames, show_drawing=show_drawing),
    pos
  )
  return ob
end

function make_lens(args...; pos, size, frames=1:100)
  ob = Object(
    frames,
    (args...) -> lens(pos, size),
  )
  return ob
end
