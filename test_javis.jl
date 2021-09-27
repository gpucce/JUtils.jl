### A Pluto.jl notebook ###
# v0.16.1

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

# ╔═╡ de66ce40-1945-11ec-19bd-53bbe9ed64c0
begin
    using Pkg
    Pkg.activate(".")
    Pkg.add("Rotations")
    using Revise,
        Javis,
        Colors,
        Images,
        PlutoUI,
        LaTeXStrings,
        LightXML,
        VideoIO,
        CoordinateTransformations,
        Rotations
    import Luxor
end

# ╔═╡ aa4c48aa-e4fd-4cf6-b731-de97e55c3540
im = convert.(RGB, Luxor.@imagematrix begin
    background("blue")
    sethue("white")
    circle(O, 10, :fill)
    box(O, 50, 50, :stroke)
end 59 59)

# ╔═╡ ab0e4338-64cc-493c-8f71-cd77ad437ffb
im2 = convert.(RGB, Luxor.@imagematrix begin
    background("blue")
    sethue("white")
    circle(O, 10, :fill)
    # rotate(π/3)
    box(O, 50, 50, :stroke)
end 151 151)

# ╔═╡ 01735a86-406a-46a8-a3c6-d3b767eaee74
Javis.crop(im2, 59, 59) == im

# ╔═╡ a2878ded-81f8-4e7d-91da-b73ace797dda
function ground(color)
    (args...) -> begin
        background(color)
        sethue("white")
    end
end

# ╔═╡ 38286288-86ff-4cee-9c58-296d0ed3c120
begin
    function ground_double_color(c11, c12, c21, c22, framenumber)
        if framenumber <= 50
            background(c11)
            sethue(c12)
        else
            background(c21)
            sethue(c22)
        end
    end
    myvideo = Video(200, 200)
    Background(1:100, (x, y, z) -> ground_double_color("blue", "black", "black", "red", z))
    circ1 = Object(1:100, JCircle(Point(0, 20), 20, action = :fill, color = "red"))
    # circ2 = Object(1:50, JCircle(Point(-20, -20), 20, action = :fill, color = "red"))
    act!(circ1, Action(anim_rotate(1π)))

    function postprocess_frame(frame_image, idx, frames)
        # frame_image = collect(imrotate(frame_image, ((idx-1)/length(frames)) * 2π))
        # frame_image
        # g(x) = RGB(1-x.r, 1-x.g, 1-x.b)
        g(x) = RGBA(x.r, x.g, x.b, 0.6)
        frame_image = g.(frame_image)
        if idx <= 50
            frame_image
        else
            frame_image[size(frame_image, 1):-1:1, size(frame_image, 2):-1:1]
        end
    end


    function postprocess_frames_flow(frames)
        [frames; reverse(frames)]
    end
    tempdir = "temp3$(join(rand('a':'z', 10)))"

    v = render(
        myvideo,
        pathname = "output.gif",
        # tempdirectory="temp",
        # postprocess_frame = postprocess_frame,
        postprocess_frames_flow = postprocess_frames_flow,
        # liveview=true
    )
end

# ╔═╡ 48f6d415-6721-49bf-9390-fbae186f1c84
v2 = let
    myvideo = Video(200, 200)
    Background(1:100, ground("black"))
    circ = Object(JCircle(Point(0, 20), 20, action = :fill, color = "white"))
    act!(circ, Action(anim_rotate(2π)))
    # tempdir = "temp3$(join(rand('a':'z', 10)))"

    v2 = render(
        myvideo,
        pathname = "output.gif",
        # tempdirectory="temp2",
        # postprocess_frame = postprocess_frame,
        # postprocess_frames_flow = postprocess_frames_flow,
        # liveview=true
    )
end

# ╔═╡ d4c10d28-b3df-4746-b2e6-22ffd12ec6bf
@bind follow_slide Slider(1:length(postprocess_frames_flow(1:50)))

# ╔═╡ 7d35d8fe-c241-4883-a2fb-7a971df76456
vec1 = load.(filter(!contains("palette"), readdir("temp", join = true)))

# ╔═╡ be1d8e1b-ed5c-4be5-a79a-85895083d6f7
vec2 = load.(filter(!contains("palette"), readdir("temp2", join = true)))

# ╔═╡ 3d2fdf5f-9c36-4000-9ae4-e765e7b6bd1f
vec1 .== vec2

# ╔═╡ ba64069c-1995-4645-a30f-8fb2361117fe
begin
    # sum(vec1[1] .!= vec2[1])
    sum(vec1[2] .!= colorant"black"), sum(vec2[2] .!= colorant"black")
end

# ╔═╡ Cell order:
# ╠═de66ce40-1945-11ec-19bd-53bbe9ed64c0
# ╠═aa4c48aa-e4fd-4cf6-b731-de97e55c3540
# ╠═ab0e4338-64cc-493c-8f71-cd77ad437ffb
# ╠═01735a86-406a-46a8-a3c6-d3b767eaee74
# ╠═a2878ded-81f8-4e7d-91da-b73ace797dda
# ╠═38286288-86ff-4cee-9c58-296d0ed3c120
# ╠═48f6d415-6721-49bf-9390-fbae186f1c84
# ╟─d4c10d28-b3df-4746-b2e6-22ffd12ec6bf
# ╠═7d35d8fe-c241-4883-a2fb-7a971df76456
# ╠═be1d8e1b-ed5c-4be5-a79a-85895083d6f7
# ╠═3d2fdf5f-9c36-4000-9ae4-e765e7b6bd1f
# ╠═ba64069c-1995-4645-a30f-8fb2361117fe
