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
  (args...) -> draw_text(
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
    (args...) -> draw_lamp(pos - r, r, max_frames, show_drawing=show_drawing),
    pos
  )
  return ob
end

function make_lens(args...; pos, size, frames=1:100)
  ob = Object(
    frames,
    (args...) -> draw_lens(pos=pos, size=size)
  )
  return ob
end

function make_doc(args...;pos, sizex, sizey, frames=1:100)
	Object(frames,
		(args...) -> draw_doc(
			pos=pos, sizex=sizex, sizey=sizey
		)
	)
end
