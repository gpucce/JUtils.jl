### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# ╔═╡ 3d1e8af8-16ef-11ec-18d8-e7fe83a40de4
begin
	using Pkg
	Pkg.activate("..")
	using Javis, JUtils, Colors
end

# ╔═╡ 985f6ae4-c559-4756-b9d7-98696c7cbf7f
begin
	function ground(args...)
		background("black")
		sethue("white")
	end
end

# ╔═╡ c25e5278-b7fa-4ec4-abcc-08617fa08872
begin
	mutable struct GArmonicSum
		α::Float64
		values::Vector{Point}
	end

	function GArmonicSum(α::Float64, start_pos::Point)
		sequence = map(k->1/k^α, 1:100)
		return GArmonicSum(
			α,
			map(1:100) do k
				start_pos + (0, -reduce(+, sequence[1:k]))
			end
		)
	end
end

# ╔═╡ caa01890-6cf5-4d6c-b26a-fd8b198baa34
GArmonicSum(0.2, O)

# ╔═╡ ef565322-cc4d-4f9d-8558-c722d490c611
function show_sum(S::GArmonicSum)
	setline(3)
	points = S.values
	for i in 1:length(S.values) - 1
		line(points[i], points[i+1], :stroke)
	end
end

# ╔═╡ f9c60c0d-9150-42e7-98ed-83d971366292
begin
	series_video = Video(500, 500)
	n_frames = 100
	Background(1:n_frames, ground)
	s1 = GArmonicSum(1.5, O)
	Object(@JShape begin
			show_sum(s1
			)
		end)
	render(series_video, pathname="../output/series_sum.gif")
end

# ╔═╡ Cell order:
# ╠═3d1e8af8-16ef-11ec-18d8-e7fe83a40de4
# ╟─985f6ae4-c559-4756-b9d7-98696c7cbf7f
# ╠═c25e5278-b7fa-4ec4-abcc-08617fa08872
# ╠═caa01890-6cf5-4d6c-b26a-fd8b198baa34
# ╠═ef565322-cc4d-4f9d-8558-c722d490c611
# ╠═f9c60c0d-9150-42e7-98ed-83d971366292
