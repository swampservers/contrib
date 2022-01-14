-- This is how we actually generate random numbers
function RandomSequence(seed, length)
    local results = {}

    for i = 1, length do
        -- Seed the random number generator - see https://wiki.facepunch.com/gmod/math.randomseed
        math.randomseed(seed)
        -- Draw the next value (a uniform value between 0 and 1) - see https://wiki.facepunch.com/gmod/math.random
        results[i] = math.random()
        -- Use the most recently drawn value as the seed for the next value
        seed = results[i]
    end

    return results
end

-- Command to generate and print the sequence
concommand.Add("verify", function(ply, cmd, args)
    -- load the arguments
    seed, count = tonumber(args[1]), tonumber(args[2])

    -- no arguments were passed
    if not seed then
        -- This command tells the server to save your seed then open the webpage
        RunConsoleCommand("showseeds")

        return
    end

    print("\nRolls for seed " .. args[1] .. "\n-----------------------")
    -- generate the sequence
    local sequence = RandomSequence(seed, count or 20)

    -- for each sample in the sequence, output it
    for i, sample in ipairs(sequence) do
        print(("Roll %2i: %.9f"):format(i, sample))
    end
end)
-- If you want, you can install this file to garrysmod/lua/autorun/client, and use the verify command in a singleplayer game, to be assured that the random functions were not tampered with.
