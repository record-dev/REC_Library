
---[[
---     files (server)
---]]

---@type boolean
local isWindows = package.config:sub(1, 1) == "\\"

---[[
---     File names inside <resource>/<path> whose name matches pattern
---]]
---@param path string relative to the resource
---@param pattern string lua pattern, "%.sql$" for example
---@return string[]
function lib.getFilesInDirectory(path, pattern)

    local files = {}

    local fullPath = ("%s/%s"):format(GetResourcePath(lib.name), path)
    local cmd = isWindows and ('dir "%s" /b'):format(fullPath:gsub("/", "\\")) or ('ls -A "%s"'):format(fullPath)

    local handle = io.popen(cmd)
    if handle == nil then
        return files
    end

    for line in handle:lines() do
        if line:match(pattern) ~= nil then
            files[#files+1] = line
        end
    end

    handle:close()

    return files
end
