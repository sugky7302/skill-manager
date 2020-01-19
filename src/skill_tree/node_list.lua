local NodeList = {}

function NodeList:insert(name, node)
  self[name] = node
end

function NodeList:query(name)
  if type(name) == 'string' then
    return self[name]
  else
    return name
  end
end

return NodeList
