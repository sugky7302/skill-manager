--[[
  StarGraph is an most important and complicated system and a powerful feature of the game.
  It expands the deep of the equipment.

  Member:
    _star_ - save the unqiue effect generated by the collection of planets and satellites.
    _planets_ - main nodes of a graph, users only cost runes to add a planet in the graph.
    _satellites_ - supported nodes of a graph. Nodes is divided into three parts. 1st and 2nd is a pair, 3rd and 4th is a pair and 5th and MAXth is a pair.
                   Every pair affects a planets' group corresponded by their same locations.

  Function:
    new() - create a new stargraph instance
      return - instance

    addPlanet(planet) - insert a planet into the _planets_.
      return - inserting true or false

    addSatellite(satellite) - insert a satellite into the _satellites_.
      return - inserting true or false
--]]

local require = require
local cls = require 'std.class'("StarGraph")
local MAX = 6

function cls:_new()
    return {
      _star_ = nil,
      _planets_ = {nil, nil, nil, nil, nil, nil},
      _satellites_ = {nil, nil, nil, nil, nil, nil}
    }
end

function cls:addPlanet(planet)
    if #self._planets_ > MAX then return false end
    self._planets_[#self._planets_+1] = planet
    return true
end

function cls:addSatellite(index, satellite)
    if #self._satellites_ > MAX or self._satellites_[index] then return false end
    self._satellites_[index] = satellite
    return true
end

return cls