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

local function find_remote_icon(remote_name, remotes, fallback)
  for _, rem in ipairs(remotes) do
    if rem.server == remote_name then
      return rem.icon
    end
  end
  return fallback
end

M.branches = function(tbl, remotes, remote_icon, local_icon)
  local branches = {}
  for _, b in ipairs(tbl) do
    local s = splitstr(b, "/")
    local branch = s[#s]
    local icon = #s > 1 and find_remote_icon(s[1], remotes, remote_icon) or local_icon
    if branch ~= "HEAD" then
      branch = string.gsub(branch, "HEAD -> ", "")
      branches[branch] = branches[branch] and branches[branch] .. icon or icon
    end
  end
  return branches
end

return M
