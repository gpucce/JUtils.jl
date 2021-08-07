module JUtils

using Colors
using Animations
using Javis
using Random
using FileIO

include("Drawings.jl")
include("Objects.jl")
include("ActingObjects.jl")

export load_and_scale, draw_thickbox
export moving_object, draw_random_point
export draw_text, make_text, moving_text
export draw_continuous_lines!
export draw_lamp, make_lamp, draw_lens, make_lens
export draw_doc, make_doc

end
