---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find helper functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

local nameOfModule = 'CSK_MultiColorSelection'

local funcs = {}
-- Providing standard JSON functions
funcs.json = require('ImageProcessing/MultiColorSelection/helper/Json')
-- Default parameters for instances of module
funcs.defaultParameters = require('ImageProcessing/MultiColorSelection/MultiColorSelection_Parameters')

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to create a list with numbers
---@param size number Size of the list
---@return string list List of numbers
local function createStringListBySize(size)
  local list = "["
  if size >= 1 then
    list = list .. '"' .. tostring(1) .. '"'
  end
  if size >= 2 then
    for i=2, size do
      list = list .. ', ' .. '"' .. tostring(i) .. '"'
    end
  end
  list = list .. "]"
  return list
end
funcs.createStringListBySize = createStringListBySize

--- Function to convert a table into a Container object
---@param content auto[] Lua Table to convert to Container
---@return Container cont Created Container
local function convertTable2Container(content)
  local cont = Container.create()
  for key, value in pairs(content) do
    if type(value) == 'table' then
      cont:add(key, convertTable2Container(value), nil)
    else
      cont:add(key, value, nil)
    end
  end
  return cont
end
funcs.convertTable2Container = convertTable2Container

--- Function to convert a Container into a table
---@param cont Container Container to convert to Lua table
---@return auto[] data Created Lua table
local function convertContainer2Table(cont)
  local data = {}
  local containerList = Container.list(cont)
  local containerCheck = false
  if tonumber(containerList[1]) then
    containerCheck = true
  end
  for i=1, #containerList do

    local subContainer

    if containerCheck then
      subContainer = Container.get(cont, tostring(i) .. '.00')
    else
      subContainer = Container.get(cont, containerList[i])
    end
    if type(subContainer) == 'userdata' then
      if Object.getType(subContainer) == "Container" then

        if containerCheck then
          table.insert(data, convertContainer2Table(subContainer))
        else
          data[containerList[i]] = convertContainer2Table(subContainer)
        end

      else
        if containerCheck then
          table.insert(data, subContainer)
        else
          data[containerList[i]] = subContainer
        end
      end
    else
      if containerCheck then
        table.insert(data, subContainer)
      else
        data[containerList[i]] = subContainer
      end
    end
  end
  return data
end
funcs.convertContainer2Table = convertContainer2Table

--- Function to select most suitable decoration for found blobs bounding box on Rules/Results UI
---@param colorValue int Color value
---@return int decoNum Number of decoration to use
local function selectRegionColor(colorValue)
  if colorValue >= 166 or colorValue <= 5 then
    return 1
  elseif colorValue >= 6 and colorValue <= 20 then
    return 2
  elseif colorValue >= 21 and colorValue <= 39 then
    return 3
  elseif colorValue >= 40 and colorValue <= 95 then
    return 4
  elseif colorValue >= 96 and colorValue <= 105 then
    return 5
  elseif colorValue >= 106 and colorValue <= 119 then
    return 6
  elseif colorValue >= 120 and colorValue <= 165 then
    return 7
  end
end
funcs.selectRegionColor = selectRegionColor

--- Function to compare table content. Optionally will fill missing values within content table with values of defaultTable
---@param content auto Data to check
---@param defaultTable auto Reference data
---@return auto[] content Update of data
local function checkParameters(content, defaultTable)
  for key, value in pairs(defaultTable) do
    if type(value) == 'table' then
      if content[key] == nil then
        _G.logger:info(nameOfModule .. ": Created missing parameters table '" .. tostring(key) .. "'")
        content[key] = {}
      end
      content[key] = checkParameters(content[key], defaultTable[key])
    elseif content[key] == nil then
      _G.logger:info(nameOfModule .. ": Missing parameter '" .. tostring(key) .. "'. Adding default value '" .. tostring(defaultTable[key]) .. "'")
      content[key] = defaultTable[key]
    end
  end
  return content
end
funcs.checkParameters = checkParameters

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************