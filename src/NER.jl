
function make_ner(; 
    n_frames, 
    height, 
    width, 
    color="black", 
    words_in, 
    words_out,
    margin=width/10
)

marg_width = width ÷ 2 - margin
marg_height = height ÷ 2 - margin
time_steps = floor.(Int, range(1, n_frames, length = 5))

Object(
    1:time_steps[end],
    (args...) -> JUtils.draw_text_doc(
        pos=O,
        sizex=100, 
        sizey=100, 
        color=color,
        n_lines=10
    )
)
n_in = length(words_in)
start_points = [(min(marg_width, marg_height) ÷ 1.5) * Point(cos(θ), -sin(θ)) for θ in (n_in > 1 ? range(π/2, -π/2, length=n_in) : [π - π/3])]
inwords = [Object(
    1:time_steps[3],
    @JShape begin
        sethue(color)
        fontsize(30)
        text(
            inword, 
            start_point,
            halign=:center,
            valign=:middle
        )
    end
) for (start_point, inword) in zip(start_points, words_in)]
for (start_point, inword) in zip(start_points, inwords)
    act!(inword, Action(time_steps[2]:time_steps[3], anim_scale(0.0)))
    act!(
        inword, 
        Action(time_steps[2]:time_steps[3], anim_translate(O - start_point))
    )
end

n_out = length(words_out)
outwords = [
    Object(
        time_steps[3]:time_steps[5],
        @JShape begin
            sethue(color)
            fontsize(30)
            text(
                outword, 
                O,
                halign=:center,
                valign=:middle
            )
    end
) for outword in words_out
]
end_points = [
    (min(marg_width, marg_height) ÷ 1.5) * Point(cos(θ), -sin(θ))
    for θ in range(-π/2, π/2, length = n_out)
    ] 
for (end_point, outword) in zip(end_points, outwords)
    act!(outword, Action(1:1, anim_scale(0.1)))
    act!(outword, Action(time_steps[1]:time_steps[2], anim_scale(1.0)))
    act!(outword, Action(time_steps[1]:time_steps[2], anim_translate(end_point)))
end
end