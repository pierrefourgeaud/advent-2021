
function part1(entries)
    c = x -> count(l -> l ∈ (2, 3, 4, 7), map(p -> length(p), x))
    return mapreduce(patterns -> c(patterns[2]), +, entries)
end

function find_index(patterns, cmp, first, last, ignore=nothing)
    return findfirst(el -> (ignore == nothing || el != patterns[ignore]) &&
                           all(c -> findfirst(isequal(c), el) != nothing, patterns[cmp]), patterns[first:last]) + first - 1
end

function find_index_rev(patterns, cmp, first, last, ignore=nothing)
    return findfirst(el -> (ignore == nothing || el != patterns[ignore]) &&
                           all(c -> findfirst(isequal(c), patterns[cmp]) != nothing, el), patterns[first:last]) + first - 1
end

function part2(entries)
    local cnt = 0
    for entry in entries
        one = 1
        seven = 2
        four = 3
        height = 10
        three = find_index(entry[1], one, 4, 6)
        nine = find_index(entry[1], four, 7, 9)
        zero = find_index(entry[1], one, 7, 9, nine)
        five = find_index_rev(entry[1], nine, 4, 6, three)
        two = 15 - three - five
        six = 24 - zero - nine

        tmpres = ""
        for pattern in entry[2]
            pattern == entry[1][zero] && (tmpres *= '0')
            pattern == entry[1][one] && (tmpres *= '1')
            pattern == entry[1][two] && (tmpres *= '2')
            pattern == entry[1][three] && (tmpres *= '3')
            pattern == entry[1][four] && (tmpres *= '4')
            pattern == entry[1][five] && (tmpres *= '5')
            pattern == entry[1][six] && (tmpres *= '6')
            pattern == entry[1][seven] && (tmpres *= '7')
            pattern == entry[1][height] && (tmpres *= '8')
            pattern == entry[1][nine] && (tmpres *= '9')
        end
        cnt += parse(Int64, tmpres)
    end
    return cnt
end

patterns = []
for line in eachline(stdin)
    tmp = split(line, " | ")
    push!(patterns, (sort(map(el -> join(sort(collect(el))), split(tmp[1], " ")), by=length),
                     map(el -> join(sort(collect(el))), split(tmp[2], " "))))
end
println("Part 1: ", part1(patterns))
println("Part 2: ", part2(patterns))
