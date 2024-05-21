return {
  map = function(table, fn)
    local result = {}
    for i, value in ipairs(table) do
      result[i] = fn(i, value)
    end
    return result
  end
}
