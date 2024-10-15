local cfg = require("persistent-breakpoints.config")
local M = {}

M.create_path = function(path)
	vim.fn.mkdir(path, "p")
end

M.get_path_sep = function()
	if jit then
		if jit.os == "Windows" then
			return "\\"
		else
			return "/"
		end
	else
		return package.config:sub(1, 1)
	end
end

M.get_bps_path = function()
	local path_sep = M.get_path_sep()
	-- local base_filename = vim.fn.getcwd()
	-- NOTE: Edit by kiyoon: instead of using the current working directory, use the git root or the current file's directory.
	local base_filename
	local project_root = vim.fs.root(0, { ".git" })
	if project_root == nil then
		base_filename = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
	else
		base_filename = project_root
	end

	if jit and jit.os == "Windows" then
		base_filename = base_filename:gsub(":", "_")
	end

	local cp_filename = base_filename:gsub(path_sep, "_") .. ".json"
	return cfg.save_dir .. path_sep .. cp_filename
end

M.load_bps = function(path)
	local fp = io.open(path, "r")
	local bps = {}
	if fp ~= nil then
		local load_bps_raw = fp:read("*a")
		bps = vim.fn.json_decode(load_bps_raw)
		fp:close()
	end
	return bps
end

M.write_bps = function(path, bps)
	bps = bps or {}
	assert(
		type(bps) == "table",
		"The persistent breakpoints should be stored in a table. Usually it is not the user's problem if you did not call the write_bps function explicitly."
	)

	local fp = io.open(path, "w+")
	if fp == nil then
		vim.notify("Failed to save checkpoints. File: " .. vim.fn.expand("%"), "WARN")
		return false
	else
		fp:write(vim.fn.json_encode(bps))
		fp:close()
		return true
	end
end

return M
