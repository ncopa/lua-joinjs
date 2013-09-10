-- Copyright (c) Natanael Copa <ncopa@alpinelinux.org>

local pos = require('posix')

-- private data
local jsfile = {}
local deps = {}

-- private methods
local function readfile(path)
	local f = io.open(path)
	if f == nil then
		return nil
	end
	local data = f:read("*all")
	f:close()
	return data
end

local function header(varname)
	return "var "..varname.." = {}\n"..
		"function require(m){return "..varname.."[m];}\n"
end

local function depsort(deps)
	local t = {}
	local visited = {}
	local added = {}
	function recurse_deps(mod)
		local k,v
		visited[mod] = true
		for k,v in pairs(deps[mod]) do
			if not visited[v] then
				recurse_deps(v)
			end
		end
		if not added[mod] then
			table.insert(t,mod)
			added[mod] = true
		end
	end
	local k,v
	for k,v in pairs(deps) do
		recurse_deps(k)
	end
	return t
end

local function find_depends(data)
	local t = {}
	local dep
	for dep in string.gmatch(data, "//%s+depends:%s*([^\n]+)") do
		table.insert(t, dep)
	end
	return t
end

-- Public functions ----------------------------------------------------
local joinjs = {}

function joinjs.dir(dir)
	local fname
	for fname in pos.files(dir) do
		if (fname):match("%.js$") then
			local data = readfile(dir.."/"..fname)
			jsfile[fname] = data
			deps[fname] = find_depends(data)
		end
	end
	return jsfile, deps
end

function joinjs.dump(varname)
	local mod, data
	local prefix = "(function(){\n"
	local suffix = "\n}());\n\n"
	varname = varname or 'joinjs_module'
	io.write(header(varname))
	local sorted = depsort(deps)
	for _,mod in pairs(sorted) do
		io.write(varname.."['"..mod.."'] = "
			..prefix..jsfile[mod]..suffix)
	end
end

function joinjs.join(varname)
	varname = varname or 'joinjs_module'
	local prefix = "(function(){\n"
	local suffix = "\n}());\n\n"
	local mod, data
	local sorted = depsort(deps)
	local js = header(varname)
	for _,mod in pairs(sorted) do
		js = js..varname.."['"..mod.."'] = "
			..prefix..jsfile[mod]..suffix
	end
	return js
end

function joinjs.reset()
	jsfile = {}
	deps = {}
end

return joinjs

