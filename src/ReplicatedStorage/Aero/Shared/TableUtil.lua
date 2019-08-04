-- Table Util
-- Crazyman32
-- September 13, 2017

--[[
	
	TableUtil.Copy(Table tbl)
	TableUtil.Sync(Table tbl, Table templateTbl)
	TableUtil.Print(Table tbl, String label, Boolean deepPrint)
	TableUtil.FastRemove(Table tbl, Number index)
	TableUtil.FastRemoveFirstValue(Table tbl, Variant value)
	TableUtil.Map(Table tbl, Function callback)
	TableUtil.Filter(Table tbl, Function callback)
	TableUtil.Reduce(Table tbl, Function callback [, Number initialValue])
	TableUtil.IndexOf(Table tbl, Variant item)
	TableUtil.Reverse(Table tbl)
	TableUtil.Shuffle(Table tbl)
	TableUtil.IsEmpty(Table tbl)
	TableUtil.EncodeJSON(Table tbl)
	TableUtil.DecodeJSON(String json)

	EXAMPLES:

		Copy:

			Performs a deep copy of the given table.

			local tbl = {"a", "b", "c"}
			local tblCopy = TableUtil.Copy(tbl)


		Sync:

			Synchronizes a table to a template table. If the table does not have an
			item that exists within the template, it gets added. If the table has
			something that the template does not have, it gets removed.

			local tbl1 = {kills = 0; deaths = 0; points = 0}
			local tbl2 = {points = 0}
			TableUtil.Sync(tbl2, tbl1)  -- In words: "Synchronize table2 to table1"
			print(tbl2.deaths)


		Print:

			Prints out the table to the output in an easy-to-read format. Good for
			debugging tables. If deep printing, avoid cyclical references.

			local tbl = {a = 32; b = 64; c = 128; d = {x = 0; y = 1; z = 2}}
			TableUtil.Print(tbl, "My Table", true)


		FastRemove:

			Removes an item from an array at a given index. Only use this if you do
			NOT care about the order of your array. This works by simply popping the
			last item in the array and overwriting the given index with the last
			item. This is O(1), compared to table.remove's O(n) speed.

			local tbl = {"hello", "there", "this", "is", "a", "test"}
			TableUtil.FastRemove(tbl, 2)   -- Remove "there" in the array
			print(table.concat(tbl, " "))  -- > hello this is a test


		FastRemoveFirstValue:

			Calls FastRemove on the first index that holds the given value.

			local tbl = {"abc", "hello", "hi", "goodbye", "hello", "hey"}
			local removed, atIndex = TableUtil.FastRemoveFirstValue(tbl, "hello")
			if (removed) then
				print("Removed at index " .. atIndex)
				print(table.concat(tbl, " "))  -- > abc hi goodbye hello hey
			else
				print("Did not find value")
			end

		
		Map:

			This allows you to construct a new table by calling the given function
			on each item in the table.

			local peopleData = {
				{firstName = "Bob"; lastName = "Smith"};
				{firstName = "John"; lastName = "Doe"};
				{firstName = "Jane"; lastName = "Doe"};
			}

			local people = TableUtil.Map(peopleData, function(item)
				return {Name = item.firstName .. " " .. item.lastName}
			end)

			-- 'people' is now an array that looks like: { {Name = "Bob Smith"}; ... }


		Filter:

			This allows you to create a table based on the given table and a filter
			function. If the function returns 'true', the item remains in the new
			table; if the function returns 'false', the item is discluded from the
			new table.

			local people = {
				{Name = "Bob Smith"; Age = 42};
				{Name = "John Doe"; Age = 34};
				{Name = "Jane Doe"; Age = 37};
			}

			local peopleUnderForty = TableUtil.Filter(people, function(item)
				return item.Age < 40
			end)


		Reduce:

			This allows you to reduce an array to a single value. Useful for quickly
			summing up an array.

			local tbl = {40, 32, 9, 5, 44}
			local tblSum = TableUtil.Reduce(tbl, function(accumulator, value)
				return accumulator + value
			end)
			print(tblSum)  -- > 130


		IndexOf:

			Returns the index of the given item in the table. If not found, this
			will return nil.

			local tbl = {"Hello", 32, true, "abc"}
			local abcIndex = TableUtil.IndexOf("abc")     -- > 4
			local helloIndex = TableUtil.IndexOf("Hello") -- > 1
			local numberIndex = TableUtil.IndexOf(64)     -- > nil


		Reverse:

			Creates a reversed version of the array. Note: This is a shallow
			copy, so existing references will remain within the new table.

			local tbl = {2, 4, 6, 8}
			local rblReversed = TableUtil.Reverse(tbl)  -- > {8, 6, 4, 2}


		Shuffle:

			Shuffles (i.e. randomizes) an array. This uses the Fisher-Yates algorithm.

			local tbl = {1, 2, 3, 4, 5, 6, 7, 8, 9}
			TableUtil.Shuffle(tbl)
			print(table.concat(tbl, ", "))  -- e.g. > 3, 6, 9, 2, 8, 4, 1, 7, 5
	
--]]



local TableUtil = {}

local http = game:GetService("HttpService")


local function CopyTable(t)
	assert(type(t) == "table", "First argument must be a table")
	local tCopy = {}
	for k,v in pairs(t) do
		if (type(v) == "table") then
			tCopy[k] = CopyTable(v)
		else
			tCopy[k] = v
		end
	end
	return tCopy
end


local function Sync(tbl, templateTbl)

	assert(type(tbl) == "table", "First argument must be a table")
	assert(type(templateTbl) == "table", "Second argument must be a table")
	
	-- If 'tbl' has something 'templateTbl' doesn't, then remove it from 'tbl'
	-- If 'tbl' has something of a different type than 'templateTbl', copy from 'templateTbl'
	-- If 'templateTbl' has something 'tbl' doesn't, then add it to 'tbl'
	for k,v in pairs(tbl) do
		
		local vTemplate = templateTbl[k]
		
		-- Remove keys not within template:
		if (vTemplate == nil) then
			tbl[k] = nil
			
		-- Synchronize data types:
		elseif (type(v) ~= type(vTemplate)) then
			if (type(vTemplate) == "table") then
				tbl[k] = CopyTable(vTemplate)
			else
				tbl[k] = vTemplate
			end
		
		-- Synchronize sub-tables:
		elseif (type(v) == "table") then
			Sync(v, vTemplate)
		end
		
	end
	
	-- Add any missing keys:
	for k,vTemplate in pairs(templateTbl) do
		
		local v = tbl[k]
		
		if (v == nil) then
			if (type(vTemplate) == "table") then
				tbl[k] = CopyTable(vTemplate)
			else
				tbl[k] = vTemplate
			end
		end
		
	end
	
end


local function FastRemove(t, i)
	local n = #t
	t[i] = t[n]
	t[n] = nil
end


local function Map(t, f)
	assert(type(t) == "table", "First argument must be a table")
	assert(type(f) == "function", "Second argument must be an array")
	local newT = {}
	for k,v in pairs(t) do
		newT[k] = f(v, k, t)
	end
	return newT
end


local function Filter(t, f)
	assert(type(t) == "table", "First argument must be a table")
	assert(type(f) == "function", "Second argument must be an array")
	local newT = {}
	if (#t > 0) then
		local n = 0
		for i = 1,#t do
			local v = t[i]
			if (f(v, i, t)) then
				n = (n + 1)
				newT[n] = v
			end
		end
	else
		for k,v in pairs(t) do
			if (f(v, k, t)) then
				newT[k] = v
			end
		end
	end
	return newT
end


local function Reduce(t, f, init)
	assert(type(t) == "table", "First argument must be a table")
	assert(type(f) == "function", "Second argument must be an array")
	assert(init == nil or type(init) == "number", "Third argument must be a number or nil")
	local result = (init or 0)
	for k,v in pairs(t) do
		result = f(result, v, k, t)
	end
	return result
end


local function Print(tbl, label, deepPrint)

	assert(type(tbl) == "table", "First argument must be a table")
	assert(label == nil or type(label) == "string", "Second argument must be a string or nil")
	
	label = (label or "TABLE")
	
	local strTbl = {}
	local indent = " - "
	
	-- Insert(string, indentLevel)
	local function Insert(s, l)
		strTbl[#strTbl + 1] = (indent:rep(l) .. s .. "\n")
	end
	
	local function AlphaKeySort(a, b)
		return (tostring(a.k) < tostring(b.k))
	end
	
	local function PrintTable(t, lvl, lbl)
		Insert(lbl .. ":", lvl - 1)
		local nonTbls = {}
		local tbls = {}
		local keySpaces = 0
		for k,v in pairs(t) do
			if (type(v) == "table") then
				table.insert(tbls, {k = k, v = v})
			else
				table.insert(nonTbls, {k = k, v = "[" .. typeof(v) .. "] " .. tostring(v)})
			end
			local spaces = #tostring(k) + 1
			if (spaces > keySpaces) then
				keySpaces = spaces
			end
		end
		table.sort(nonTbls, AlphaKeySort)
		table.sort(tbls, AlphaKeySort)
		for _,v in pairs(nonTbls) do
			Insert(tostring(v.k) .. ":" .. (" "):rep(keySpaces - #tostring(v.k)) .. v.v, lvl)
		end
		if (deepPrint) then
			for _,v in pairs(tbls) do
				PrintTable(v.v, lvl + 1, tostring(v.k) .. (" "):rep(keySpaces - #tostring(v.k)) .. " [Table]")
			end
		else
			for _,v in pairs(tbls) do
				Insert(tostring(v.k) .. ":" .. (" "):rep(keySpaces - #tostring(v.k)) .. "[Table]", lvl)
			end
		end
	end
	
	PrintTable(tbl, 1, label)
	
	print(table.concat(strTbl, ""))
	
end


local function IndexOf(tbl, item)
	for i = 1,#tbl do
		if (tbl[i] == item) then
			return i
		end
	end
	return nil
end


local function Reverse(tbl)
	local tblRev = {}
	local n = #tbl
	for i = 1,n do
		tblRev[i] = tbl[n - i + 1]
	end
	return tblRev
end


local function Shuffle(tbl)
	assert(type(tbl) == "table", "First argument must be a table")
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end


local function IsEmpty(tbl)
	return (next(tbl) == nil)
end


local function EncodeJSON(tbl)
	return http:JSONEncode(tbl)
end


local function DecodeJSON(str)
	return http:JSONDecode(str)
end


local function FastRemoveFirstValue(t, v)
	local index = IndexOf(t, v)
	if (index) then
		FastRemove(t, index)
		return true, index
	end
	return false, nil
end


TableUtil.Copy = CopyTable
TableUtil.Sync = Sync
TableUtil.FastRemove = FastRemove
TableUtil.FastRemoveFirstValue = FastRemoveFirstValue
TableUtil.Print = Print
TableUtil.Map = Map
TableUtil.Filter = Filter
TableUtil.Reduce = Reduce
TableUtil.IndexOf = IndexOf
TableUtil.Reverse = Reverse
TableUtil.Shuffle = Shuffle
TableUtil.IsEmpty = IsEmpty
TableUtil.EncodeJSON = EncodeJSON
TableUtil.DecodeJSON = DecodeJSON


return TableUtil