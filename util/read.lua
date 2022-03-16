local read = {}

function read.output(cmd)
    local file = assert(io.popen(cmd, "r"))
    local output = file:read "*all"
    file:close()

    return output
end

return read
