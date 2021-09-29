### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ de66ce40-1945-11ec-19bd-53bbe9ed64c0
begin
    using Pkg
    Pkg.activate(".")
    using Revise
    using Javis
    using Colors
    using Images
    using PlutoUI
    using LaTeXStrings
    using LightXML
    using VideoIO
    using CoordinateTransformations
    using Rotations
	using BenchmarkTools
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
        Luxor.background(color)
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
        postprocess_frame = postprocess_frame,
        # postprocess_frames_flow = postprocess_frames_flow,
        # liveview=true
    )
end

# ╔═╡ 00849422-a792-46c4-9623-06b3ee0a3750
N0f8

# ╔═╡ 48f6d415-6721-49bf-9390-fbae186f1c84
@btime let
    myvideo = Video(200, 200)
    Background(1:100, ground("black"))
    circ = Object(JCircle(Point(0, 20), 20, action = :fill, color = "white"))
    act!(circ, Action(anim_rotate(2π)))
    # tempdir = "temp3$(join(rand('a':'z', 10)))"

    render(
        myvideo,
        pathname = "output.gif",
    )
end

# ╔═╡ Cell order:
# ╠═de66ce40-1945-11ec-19bd-53bbe9ed64c0
# ╠═aa4c48aa-e4fd-4cf6-b731-de97e55c3540
# ╠═ab0e4338-64cc-493c-8f71-cd77ad437ffb
# ╠═01735a86-406a-46a8-a3c6-d3b767eaee74
# ╠═a2878ded-81f8-4e7d-91da-b73ace797dda
# ╠═38286288-86ff-4cee-9c58-296d0ed3c120
# ╠═00849422-a792-46c4-9623-06b3ee0a3750
# ╠═48f6d415-6721-49bf-9390-fbae186f1c84
