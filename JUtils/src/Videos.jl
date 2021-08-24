function CLT(dist;
  boundingbox = BoundingBox(O + (-250, -120), O + (250, 120)),
  bargap=10,
  margin = 5,
  border=false,
  )


  n_frames = 700
  n_hists = 700
  n_samples = 10000

  c1 = HSV(colorant"goldenrod1")
  c2 = HSV(240, c1.s, c1.v)

  samples = map(1:n_hists) do n
    map(1:n_samples) do _
    (mean(rand(dist, n)) - mean(dist)) * sqrt(n)
    end
  end

  finalmin, finalmax = extrema(samples[end])

  steps = map(samples) do sampling
    hist = fit(Histogram, sampling,
      weights(ones(length(sampling))),
      range(finalmin, finalmax, length=100)
    )
    hist = StatsBase.normalize(hist, mode=:pdf)
    hist
  end

  

  gauss = Normal(0, StatsBase.std(dist))

  my_video = Video(600, 500)

  function ground(args...)
    background("white")
    sethue("black")
  end

  function moving_gaussian(hist, minbarrange, maxbarrange, barchartheight; color)
    (values, i, lowpos, highpos, barwidth, scaledvalue) -> begin
      sethue(color)
      if i <= length(hist.edges[1])
        scaledgaussvalue = rescale(
        pdf(gauss, hist.edges[1][i+1] - hist.edges[1].step.hi/2),
        minbarrange,
        maxbarrange
        ) * barchartheight
        circle(lowpos - (0, scaledgaussvalue), 3, :fill)
      end
      sethue("black")
    end
  end

  function fixed_gaussian(loc_hist; color)
    (values, i, lowpos, highpos, barwidth, scaledvalue) -> begin
    
      minvalue, maxvalue = extrema(loc_hist.weights)
      barchartheight = boxheight(boundingbox) - 2margin
      minbarrange = minvalue - abs(minvalue)
      maxbarrange = maxvalue + abs(maxvalue)
    
      sethue(color)
      if i <= length(loc_hist.edges[1])
        scaledgaussvalue = rescale(
          pdf(gauss, loc_hist.edges[1][i+1] - loc_hist.edges[1].step.hi/2),
          minbarrange,
          maxbarrange
          ) * barchartheight
        circle(lowpos - (0, scaledgaussvalue), 3, :fill)
      end
      
      tickline(
          boxbottomleft(boundingbox) - Point(0, margin), 
          boxbottomright(boundingbox) - Point(0, margin),
          startnumber = loc_hist.edges[1][1],
          finishnumber = loc_hist.edges[1][end]
      )

      sethue("black")
    end
  end

  function mybarfunction(;color)
    (values, i, lowpos, highpos, barwidth, scaledvalue) -> begin
      Luxor.@layer begin
        sethue(color)
        Luxor.setline(barwidth)
        line(lowpos, highpos, :stroke)
        sethue(color)
      end
    end
  end

  Background(1:n_frames, ground)

  step_size = n_frames ÷ n_hists
  frame_brakes = 1:step_size:n_frames
  titlepoint = Point(0, -100)
  distpoint = Point(-200, 0)
  counterpoint = Point(200, 0)

  final_hist = steps[end]

  for (frame_n, hist) in zip(frame_brakes, steps[2:end])

    # minvalue, maxvalue = extrema(hist.weights)
    # barchartheight = boxheight(boundingbox) - 2margin
    # minbarrange = minvalue - abs(minvalue)
    # maxbarrange = maxvalue + abs(maxvalue)

    Object(frame_n:frame_n + step_size, @JShape begin
      barchart(
        hist.weights,
        boundingbox=boundingbox,
        bargap=bargap,
        margin=margin,
        border=border,
        labels=true,
        barfunction=mybarfunction(color=c1),

        ## Normalizes gaussian at every iteration
        # labelfunction = moving_gaussian(
        #     final_hist,
        #     minbarrange,
        #     maxbarrange,
        #     barchartheight,
        #     color=c2
        # )

        ## Normalize gaussian using last iteration values
        labelfunction = fixed_gaussian(
            final_hist,
            color=c2
        )
      )
      end
    )

    Object(frame_n:frame_n+step_size, @JShape begin
      sethue(c1)
      fontsize(15)
      text(string(frame_n ÷ step_size), counterpoint, halign=:center)
      sethue("black")
    end)
    
  end

  Object(
    1:n_frames,
    @JShape begin
      fontsize(40)
      text("Central Limit Theorem", titlepoint, halign=:center)

      fontsize(20)
      label("Iteration", :N, counterpoint, offset=20)
      label("Distribution", :N, distpoint, offset=20)

      sethue(c1)
      fontsize(15)
      text(
        join([string(typeof(dist).name.name); string(params(dist))], ""),
        distpoint,
        halign=:center
      )
  end
  )

  render(my_video, framerate=100, pathname="output/CLT.gif")
end
