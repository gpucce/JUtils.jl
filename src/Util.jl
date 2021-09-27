function specificity(tar, nontar, p)
    sum(nontar .< p) / length(nontar)
end

function sensitivity(tar, nontar, p)
    sum(tar .>= p) / length(tar)
end
