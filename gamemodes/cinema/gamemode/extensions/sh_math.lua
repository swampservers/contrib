-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

-- Ceil the given number to the largest power of two
function math.power2(n)
	return math.pow(2, math.ceil(math.log(n) / math.log(2)))
end
