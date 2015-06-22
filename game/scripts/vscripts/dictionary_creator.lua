--script which splits one big dictionary into difficulties and then outputs them as lua table for you to use

file = io.open("dictionary.txt", "r")
io.input(file)

local easy = {}
local medium = {}
local hard = {}

while true do
	local line = io.read()
	if line == nil then break end
	if string.len(line) <=6 then
		table.insert(easy,line)
	elseif string.len(line) >6 and string.len(line) <=9 then
		table.insert(medium,line)
	elseif string.len(line) >9 then
		table.insert(hard,line)
	end
end
file:close()




file = io.open("easy.txt","a")
file:write("local dict_easy = {\n")
for _,v in pairs(easy) do
	file:write('"'..v..'",\n')
end
file:write("\n}")
file:close()


file = io.open("medium.txt", "w")
file:write("local dict_medium = {\n")
for _,v in pairs(medium) do
	file:write('"'..v..'",\n')
end
file:write("\n}")
file:close()


file = io.open("hard.txt", "w")
file:write("local dict_hard = {\n")
for _,v in pairs(hard) do
	file:write('"'..v..'",\n')
end
file:write("\n}")
file:close()
