### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# ╔═╡ ae3abb60-13d1-11ec-0142-0fe32f29a9cf
begin 
using Pkg
Pkg.activate(".")
using Javis, Animations
end

# ╔═╡ c19adf8b-43af-4a55-b54f-de3b60855d83
begin
function ground(args...)
    background("black") # canvas background
    sethue("white") # pen color
end

function object(p=O, color="black")
    sethue(color)
    circle(p, 25, :fill)
    return p
end

function path!(points, pos, color)
    sethue(color)
    push!(points, pos) # add pos to points
    circle.(points, 2, :fill) # draws a circle for each point using broadcasting
end

function dancing_circles(c1, c2, start_pos=O)
	path_of_red = Point[]
    path_of_blue = Point[]
		
	red_ball = Object((args...)->object(O, c1), start_pos + Point(100, 0))
    act!(red_ball, Action(anim_rotate_around(2π, start_pos)))
    blue_ball = Object((args...)->object(O, c2), start_pos + Point(200, 80))
    act!(blue_ball, Action(anim_rotate_around(2π, 0.0, red_ball)))
    Object((args...)->path!(path_of_red, pos(red_ball), c1))
    Object((args...)->path!(path_of_blue, pos(blue_ball), c2))
end
end

# ╔═╡ 51c3ad95-846b-420d-8be3-e82daf11ee5f
begin
colored_planets = Video(500, 500)

Background(1:70, ground)

dancing_circles("green", "orange")

render(
		colored_planets,
		pathname="../output/colored_dancing_circles.gif"
	)
end

# ╔═╡ 99beeaf4-1a48-4b7f-b48d-16b2705c1992
let
	
moving_colored_planets = Video(500, 500)
Background(1:140, ground)

l1 = @JLayer 1:140 begin
    dancing_circles("green", "orange")
end

act!(l1, Action(1:1, anim_scale(0.4)))
	
animation_point = Point(-75, -75)
anim_back_and_forth = Animation(
		[0, 1/2, 1],
		[animation_point, -animation_point, animation_point],
		[sineio(), sineio()]
	)
	

act!(l1, Action(1:140, anim_back_and_forth, translate()))

render(moving_colored_planets, pathname="../output/1_moving_colored_dancing_circles.gif")
end

# ╔═╡ 3cc96cf6-1d12-4615-81af-f2529e0d7795
let
	
finalvideo = Video(500, 500)

Background(1:140, ground)

colors = [
    ["red", "green"],
    ["orange", "blue"],
    ["yellow", "purple"],
    ["greenyellow", "darkgoldenrod1"]
]

final_points = [
    Point(-150, -150),
    Point(150, -150),
    Point(150, 150),
    Point(-150, 150),
]

planets = map(colors) do c
    @JLayer 1:140 begin
        dancing_circles(c...) 
    end
end

anim_back_and_forth = map(final_points) do point
    Animation(
        [0.0, 1/2, 1.0],
        [O, point, O],
        [sineio(), sineio()]
    )
end

map(zip(anim_back_and_forth, planets)) do (animation, pl)
    act!(pl, Action(1:1, anim_scale(0.4)))
    act!(pl, Action(1:140, animation, translate(), keep=false))
end

render(finalvideo; pathname="../output/4_moving_colored_dancing_circles.gif")
end

# ╔═╡ Cell order:
# ╠═ae3abb60-13d1-11ec-0142-0fe32f29a9cf
# ╠═c19adf8b-43af-4a55-b54f-de3b60855d83
# ╠═51c3ad95-846b-420d-8be3-e82daf11ee5f
# ╠═99beeaf4-1a48-4b7f-b48d-16b2705c1992
# ╠═3cc96cf6-1d12-4615-81af-f2529e0d7795
