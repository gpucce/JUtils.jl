function CLT(
    dist;
    boundingbox = BoundingBox(O + (-250, -120), O + (250, 120)),
    margin = 5,
    pathname = "central_limit_theorem",
)

    function ground(args...)
        background("black")
        sethue("white")
    end

    function fixed_gaussian(loc_hist; color)
        (values, i, lowpos, highpos, barwidth, scaledvalue) -> begin

            minvalue, maxvalue = extrema(loc_hist.weights)
            barchartheight = boxheight(boundingbox) - 2margin
            minbarrange = minvalue - abs(minvalue)
            maxbarrange = maxvalue + abs(maxvalue)
            @layer begin

                sethue(color)
                if i <= length(loc_hist.edges[1])
                    scaledgaussvalue =
                        rescale(
                            pdf(
                                gauss,
                                loc_hist.edges[1][i + 1] - loc_hist.edges[1].step.hi / 2,
                            ),
                            minbarrange,
                            maxbarrange,
                        ) * barchartheight
                    circle(lowpos - (0, scaledgaussvalue), 3, :fill)
                end
            end

            tickline(
                boxbottomleft(boundingbox) - Point(0, margin),
                boxbottomright(boundingbox) - Point(0, margin),
                startnumber = loc_hist.edges[1][1],
                finishnumber = loc_hist.edges[1][end],
            )
        end
    end

    function hist_bar(; color)
        (values, i, lowpos, highpos, barwidth, scaledvalue) -> begin
            @layer begin
                sethue(color)
                Luxor.setline(barwidth)
                line(lowpos, highpos, :stroke)
            end
        end
    end


    # Parameters for the barchart function 
    boundingbox = BoundingBox(O + (-250, -120), O + (250, 120))
    margin = 5


    # number of frames
    n_frames = 700

    # Number of histograms shown. To make the animation
    # slower set this to a lower value, less histograms
    # will be shown but they will reach the same n for 
    # convergence as set by n_frames
    n_hists = 700

    # number of samples at each n 
    n_samples = 10000

    # Change to adjust bar colors and gauss colors
    barcolor = HSV(colorant"goldenrod1")
    gausscolor = HSV(240, barcolor.s, barcolor.v)

    # Sample the mean r.v. for increasing values of n (1 to n_hists)
    samples = map(1:n_hists) do n
        map(1:n_samples) do _
            (mean(rand(dist, n)) - mean(dist)) * sqrt(n)
        end
    end

    finalmin, finalmax = extrema(samples[end])

    # Turn the samples into histograms
    steps = map(samples) do sampling
        hist = fit(
            Histogram,
            sampling,
            weights(ones(length(sampling))),
            range(finalmin, finalmax, length = 100),
        )
        hist = StatsBase.normalize(hist, mode = :pdf)
        hist
    end

    # Define the gaussian distribution where they should converge
    gauss = Normal(0, StatsBase.std(dist))

    my_video = Video(800, 800)
    Background(1:n_frames, ground)

    step_size = n_frames ÷ n_hists
    frame_brakes = 1:step_size:n_frames

    # Fix some point where writings will be shown
    titlepoint = Point(0, -100)
    distpoint = Point(-200, 0)
    counterpoint = Point(200, 0)

    # The last and thus hopefully most closely converged histogram in our sequence
    final_hist = steps[end]

    for (frame_n, hist) in zip(frame_brakes, steps)

        Object(
            frame_n:(frame_n + step_size - 1),
            @JShape begin
                barchart(
                    hist.weights,
                    boundingbox = boundingbox,
                    margin = margin,
                    labels = true,

                    # Provide the hist_bar we defined as the barfunction 
                    barfunction = hist_bar(color = barcolor),

                    # Provide the fixed_gaussian we defined as the labelfunction
                    # it will plot the gaussian dots and the ticks on the bottom
                    labelfunction = fixed_gaussian(final_hist, color = gausscolor),
                )
            end
        )

        # The counter digits
        Object(
            frame_n:(frame_n + step_size - 1),
            @JShape begin
                sethue(barcolor)
                fontsize(15)
                text(string(frame_n ÷ step_size), counterpoint, halign = :center)
            end
        )
    end

    # All the writings except the changing digit.
    Object(
        1:n_frames,
        @JShape begin
            fontsize(40)
            text("Central Limit Theorem", titlepoint, halign = :center)

            fontsize(20)
            label("N", :N, counterpoint, offset = 20)
            label("Distribution", :N, distpoint, offset = 20)

            sethue(barcolor)
            fontsize(15)
            text(
                # Gather the distribution name and parameters
                # only works if dist is from Distributions.jl
                join([string(typeof(dist).name.name); string(params(dist))], ""),
                distpoint,
                halign = :center,
            )
        end
    )


    render(my_video, pathname = pathname)
end


function pendulum(;
    shift = O,
    basepoint = shift + O,
    radius = 300,
    margin = 10,
    k = 0.7π,
    first_frame = 1,
    last_frame = 500,
    speed_up = 3,
)

    ## Constants
    n_frames = last_frame - first_frame

    ## Constant shapes
    Object(first_frame:last_frame, (args...) -> arc(O, radius, 0, π, :stroke))
    Object(
        first_frame:last_frame,
        (args...) -> Javis.latex(
            L"\Huge{\theta(t) = \pi e^{-\frac{t}{\tau}} \cos(\omega t)}",
            Point(150, -300),
            :middle,
            :center,
        ),
    )
    Object(
        first_frame:last_frame,
        JLine(basepoint - (radius, 0), basepoint + (radius, 0), color = "white"),
    )
    Object(
        first_frame:last_frame,
        JLine(basepoint, basepoint + (0, radius), color = "white"),
    )
    Object(
        first_frame:last_frame,
        JLine(
            Point(-radius, -radius / 2 - margin),
            Point(radius, -radius / 2 - margin),
            linewidth = 1,
            color = "white",
        ),
    )

    Object(
        first_frame:last_frame,
        @JShape begin
            setline(2)
            tickline(
                Point(-radius, -radius - margin),
                Point(-radius, -margin),
                startnumber = k,
                finishnumber = -k,
            )
        end
    )


    motion(t) = k * ℯ^(-3 * (t) / 2) * cos(10t)

    points = map(first_frame:last_frame) do idx
        # Frame constants
        t = speed_up * (idx - first_frame + 1) / n_frames
        p = shift + radius * Point(sin(motion(t)), cos(motion(t)))
        endpoint = shift + p

        # Lines
        Object(idx:idx, @JShape begin
            setline(3)
            sethue("white")
            line(basepoint, shift + p, :stroke)
            setline(1)
            sethue("orange")
            line(endpoint, Point(endpoint.x, 0), :stroke)
            line(endpoint, Point(0, endpoint.y), :stroke)
        end)
        Object(idx:idx, JCircle(endpoint, 20, action = :fill, color = "red"))

        # Labels
        Object(
            idx:idx,
            (args...) -> begin
                fontsize(25)
                cos_x_val = midpoint(basepoint, endpoint).x
                Javis.latex(
                    L"\sin(\theta)",
                    Point(cos_x_val, endpoint.y) + (0, -10),
                    :middle,
                    :center,
                )
                sin_y_val = midpoint(basepoint, endpoint).y
                Javis.latex(
                    L"\cos(\theta)",
                    Point(endpoint.x, sin_y_val) + (-4, 0),
                    :middle,
                    :center,
                )
            end,
        )

        # Arcs
        Object(
            idx:idx,
            (args...) -> begin
                mypoint = Point(sin(motion(t)), cos(motion(t)))
                if motion(t) < 0
                    move(Point(0, 40))
                    arc(basepoint, 40, π / 2, π / 2 - motion(t), :stroke)
                else
                    move(40 * mypoint)
                    arc(basepoint, 40, π / 2 - motion(t), π / 2, :stroke)
                end
                fontsize(25)
                Javis.latex(L"\theta", basepoint + (-2margin, 2margin), :middle, :center)
            end,
        )


        Object(
            idx:idx,
            (args...) -> begin
                # Tangent component
                Luxor.arrow(
                    endpoint,
                    endpoint +
                    radius / 3 *
                    cos(motion(t) - π / 2) *
                    Point(sin(motion(t) - π / 2), cos(motion(t) - π / 2)),
                    linewidth = 2,
                )

                # Perpendicular component
                Luxor.arrow(
                    endpoint,
                    endpoint +
                    radius / 3 *
                    sin(motion(t) - π / 2) *
                    Point(-cos(motion(t) - π / 2), sin(motion(t) - π / 2)),
                    linewidth = 2,
                )

                # Full force
                sethue("grey")
                Luxor.arrow(endpoint, endpoint + radius / 3 * Point(0, 1))
            end,
        )

        # Plot
        Object(
            idx:last_frame,
            JCircle(
                Point(
                    -radius +
                    margin +
                    (idx - first_frame + 1) * (2 * radius - margin) / n_frames,
                    -radius / 2 - margin - radius * motion(t) / 2k,
                ),
                2,
                action = :fill,
                color = "red",
            ),
        )
    end

    Object(first_frame:last_frame, JCircle(basepoint, 10, action = :fill, color = "blue"))

end





