### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# ╔═╡ 76e86802-19f0-11ec-0a0b-bfa6661be4f4
begin
    using Pkg
    Pkg.activate("..")
    using Javis, Random
    import Luxor
end

# ╔═╡ 630d8562-c784-4fc4-8180-222d913e5075
function ground(args...)
    background("blue")
    sethue("white")
end

# ╔═╡ a4477fbe-bdac-4e1c-8750-29fa62931968
mandel(z, c) = z^2 + c

# ╔═╡ 5be12534-6203-49a2-b64b-37076945bfaf
function mandelcheck(c, n, thr)
    out = mandel(0, c)
    k = 1
    while (k < n) | (abs(out) > thr)
        out = mandel(out, c)
        k += 1
    end
    out
end

# ╔═╡ a1b464f7-86c4-4eb4-933a-71a476c45c59
function draw_mandelbrot(width, height)
    thr = 100
    points = [
        Complex(i, j) for i in range(-2, 1 / 2, length = width),
        j in range(-1.5, 1.5, length = height)
    ]
    positions = CartesianIndices(points)
    origin(Point(0, 0))
    map(positions) do position
        if abs(mandelcheck(points[position], 20, thr)) < thr
            sethue(rand(["blue", "red", "orange"]))
            circle(Point(position[1], position[2]), 1, :fill)
        end
    end
end

# ╔═╡ 4eb94c31-dce3-4d09-8515-5a54ad077878
begin
    width = 500
    height = 500
    image = Luxor.@draw begin
        background("blue")
        draw_mandelbrot(500, 500)
    end width height
end

# ╔═╡ fc8bc0a2-602f-4700-9529-165692d044e2
function make_mandelbrot(width, height, n_frames, n_points; shape_lasting = 100)
    thr = 100
    points = [
        Complex(i, j) for i in range(-2, 1 / 2, length = n_points),
        j in range(-1.3, 1.3, length = n_points)
    ]
    positions = [
        (i, j) for i in range(1, height, length = size(points, 1)),
        j in range(1, width, length = size(points, 2))
    ]
    mask = abs.(mandelcheck.(points, 20, thr)) .< thr
    points = points[mask]
    positions = positions[mask]

    final_appearing_frame = n_frames - shape_lasting
    indices = shuffle(1:length(positions))
    map(zip(indices, positions, points)) do (idx, position, point)
        Object(
            floor(Int, rescale(idx, 2, length(positions), 1, final_appearing_frame)):n_frames,
            @JShape begin
                origin(O)
                sethue("orange")
                circle(Point(position...), 2, :fill)
            end
        )
    end
end

# ╔═╡ 15355ca2-64ca-41e9-b1ad-a3c4eaa14e01
let
    height, width = 500, 500
    n_frames = 500
    n_points = 200
    mandelvideo = Video(width, height)
    Background(1:n_frames, ground)
    make_mandelbrot(width, height, n_frames, n_points, shape_lasting = 100)
    render(mandelvideo, pathname = "../output/mandelbrot.gif")
end

# ╔═╡ Cell order:
# ╠═76e86802-19f0-11ec-0a0b-bfa6661be4f4
# ╠═630d8562-c784-4fc4-8180-222d913e5075
# ╠═a4477fbe-bdac-4e1c-8750-29fa62931968
# ╠═5be12534-6203-49a2-b64b-37076945bfaf
# ╠═4eb94c31-dce3-4d09-8515-5a54ad077878
# ╠═a1b464f7-86c4-4eb4-933a-71a476c45c59
# ╠═fc8bc0a2-602f-4700-9529-165692d044e2
# ╠═15355ca2-64ca-41e9-b1ad-a3c4eaa14e01
