local M = {}

local function splitstr(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

local function find_server_icon(remote_name, remotes, fallback)
	for _, rem in ipairs(remotes) do
		if rem.server == remote_name then
			return rem.icon
		end
	end
	return fallback
end

local function find_server_highlight(remote_name, remotes)
	for _, rem in ipairs(remotes) do
		if rem.server == remote_name then
			return rem.highlight
		end
	end
	return ""
end

-- returns:
-- branches['main'] = {"origin", "local"}
-- branches['dev'] = {"local"}
local function branch_groups(tbl)
	local branches = {}

	for _, b in ipairs(tbl) do
		-- s = ['origin', 'main'] or just ['main']
		local s = splitstr(b, "/")

		-- branch = ['main']
		local branch = s[#s]

		-- skip "head", it's not a branch
		if branch ~= "head" then
			-- remove leading "head ->" on branches that happen to be at head
			branch = string.gsub(branch, "head %-> ", "")

			-- make sure branches[branch] is empty if it doesn't exist already
			branches[branch] = branches[branch] and branches[branch] or {}

			if #s == 1 then -- no server, so must be a local branch
				-- append local icon
				table.insert(branches[branch], "")
			else
				-- prepend remove icon
				table.insert(branches[branch], 1, s[1])
			end
		end
	end

	return branches
end

-- returns
-- branchlist[1] = { icons = "Xo",
-- 					 name = "main",
-- 					 highlights = {
-- 					     {hg = "origin", start = 2, stop = 3},
-- 					     {hg = "LOCAL", start = 3, stop = 4}
-- 			       }

M.branches = function(tbl, remotes, fallback_remote_icon)
	local branches = {}

	local bgroups = branch_groups(tbl)
	for name, servers in pairs(bgroups) do
		local icons = ""
		local hls = {}
		for i, server in ipairs(servers) do
			icons = icons .. find_server_icon(server, remotes, fallback_remote_icon)
			table.insert(hls, {
				hg = find_server_highlight(server, remotes),
				start = i,
				stop = i + 1
			})
		end
		branches[#branches + 1] = {}
		branches[#branches].icons = icons
		branches[#branches].name = name
		branches[#branches].highlights = hls
	end

	return branches
end


return M
