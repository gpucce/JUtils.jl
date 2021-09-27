### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ e3a36f34-f16e-11eb-0480-43a3e559f803
begin
    using Pkg
    Pkg.activate("..")
    using Revise,
        Javis, Animations, PlutoUI, Random, Colors, FileIO, JUtils, Distributions, StatsBase
    φ = Base.MathConstants.φ
    import Luxor
end

# ╔═╡ 3d896c63-b553-49a6-a901-c34688fedeeb
md"""
# Test Video
"""

# ╔═╡ d9a4d4e5-16ca-4d26-b18d-6be136ba6ee9
@bind parole PlutoUI.TextField(default = "Ciao")

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
    # max_frames = 50

    # test_video = Video(350, 350)
    # Background(1:max_frames, ground)
    # # Object(1:max_frames, (args...)-> circle(O, 3, :fill))
    # for i in 1:1
    # d = make_banner(pos=Point(0,0), sizex=300, sizey=200, frames=1:max_frames, rng=43, 
    # 			words=split(parole))
    # moving_object(d, start_point=Point(0,0), final_point=Point(10,0), frames=25:50)
    # end
    # render(test_video, pathname="test.gif")
end

# ╔═╡ 383c4044-8e9b-42b4-b93b-cb7578ba5dc0
let
    n_frames = 400
    n_parts = 12
    height_text = -150
    height_1 = 0
    video_width = 800
    video_height = 400
    video = Video(video_width, video_height)
    starts = [1; [n_frames ÷ n_parts * i for i in 1:(n_parts - 1)]]
    stops = [n_frames ÷ n_parts * i for i in 1:n_parts]

    bg = Background(1:n_frames, ground)

    # ALL TEXTS
    texts = [
        make_text(
            body = "Have an Idea",
            text_frames = starts[1]:stops[2],
            action_frames = 1:(stops[2] - stops[1] ÷ 3),
            size = 50,
            pos = Point(0, height_text),
            halign = :center,
        ),
        make_text(
            body = "Gather Data",
            text_frames = starts[4]:stops[6],
            action_frames = 1:(stops[1] - stops[1] ÷ 3),
            size = 50,
            pos = Point(0, height_text),
            halign = :center,
        ),
    ]

    # ALL ARROWS
    arrows = [
        Object(
            starts[3]:stops[6],
            (args...) -> arrow(Point(-150, height_1), Point(150, height_1)),
            linewidth = 5,
        ),
        Object(
            starts[9]:n_frames,
            (args...) -> arrow(Point(-100, height_1), Point(100, height_1)),
            linewidth = 5,
        ),
    ]

    act!(arrows[1], Action(1:stops[1], appear(:scale)))

    # ROUND 1 
    bulb = Object(
        stops[1]:stops[6],
        (args...) -> draw_lamp(O, 40, n_frames),
        Point(-video_width ÷ 2 + 100, height_1 - 40),
    )

    act!(bulb, Action(1:stops[1], appear(:fade)))

    # ROUND 2 	
    lens = make_lens(pos = Point(0, height_1 - 70), size = 20, frames = starts[3]:stops[6])

    # ROUND 3


    r_p = draw_random_point(100, 200)
    real_doc = make_doc(pos = r_p, sizex = 100, sizey = 110, frames = starts[5]:n_frames)

    moving_object(
        real_doc,
        start_point = r_p,
        final_point = Point(video_width ÷ 2 - 100, height_1),
        frames = 1:stops[1],
    )

    obs = [real_doc]
    for i in 1:9
        r_p = draw_random_point(100, 200)
        ob = make_doc(pos = r_p, sizex = 100, sizey = 110, frames = starts[5]:stops[6])
        push!(obs, ob)
        moving_object(
            ob,
            start_point = r_p,
            final_point = Point(video_width ÷ 2 - 100, height_1),
            frames = 1:stops[1],
        )
    end

    moving_object(
        real_doc,
        start_point = Point(video_width ÷ 2 - 100, height_1),
        final_point = Point(-video_width ÷ 2 + 150, height_1 +
                                                    # add correction because scale does not keep the center
                                                    110 ÷ 2),
        frames = starts[3]:stops[3],
    )

    act!(real_doc, Action(starts[3]:stops[3], anim_scale(1.5)))


    banner = make_banner(
        pos = Point(video_width ÷ 2 - 150, height_1),
        sizex = 200,
        frames = starts[10]:n_frames,
        rng = 43,
        # body="DESIGN"
    )

    act!(banner, Action(1:stops[1], appear(:fade)))

    render(video, pathname = "../output/process_animation.gif")
end

# ╔═╡ Cell order:
# ╠═e3a36f34-f16e-11eb-0480-43a3e559f803
# ╟─3d896c63-b553-49a6-a901-c34688fedeeb
# ╟─d9a4d4e5-16ca-4d26-b18d-6be136ba6ee9
# ╟─975c3747-7922-4619-85c9-62bcb0a7a1fe
# ╠═383c4044-8e9b-42b4-b93b-cb7578ba5dc0
# ╟─3bb08101-95c8-4dff-9516-67226c852392
# ╟─87ace88b-2fe6-4d01-8c01-f4b8a2c31384
