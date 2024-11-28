---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- Load all relevant APIs for this module
--**************************************************************************

local availableAPIs = {}

-- Function to load all default APIs
local function loadAPIs()
  CSK_MultiColorSelection = require 'API.CSK_MultiColorSelection'

  Log = require 'API.Log'
  Log.Handler = require 'API.Log.Handler'
  Log.SharedLogger = require 'API.Log.SharedLogger'

  Container = require 'API.Container'
  Engine = require 'API.Engine'
  Object = require 'API.Object'
  Timer = require 'API.Timer'

  -- Check if related CSK modules are available to be used
  local appList = Engine.listApps()
  for i = 1, #appList do
    if appList[i] == 'CSK_Module_PersistentData' then
      CSK_PersistentData = require 'API.CSK_PersistentData'
    elseif appList[i] == 'CSK_Module_UserManagement' then
      CSK_UserManagement = require 'API.CSK_UserManagement'
    elseif appList[i] == 'CSK_Module_FlowConfig' then
      CSK_FlowConfig = require 'API.CSK_FlowConfig'
    end
  end
end

-- Function to load specific APIs
local function loadSpecificAPIs()
  DateTime = require 'API.DateTime'
  Image = require 'API.Image'
  Image.PixelRegion = require 'API.Image.PixelRegion'
  Point = require 'API.Point'
  Shape = require 'API.Shape'
  Shape.Composite = require 'API.Shape.Composite'
  View = require 'API.View'
  View.PixelRegionDecoration = require 'API.View.PixelRegionDecoration'
  View.ShapeDecoration = require 'API.View.ShapeDecoration'
end

availableAPIs.default = xpcall(loadAPIs, debug.traceback) -- TRUE if all default APIs were loaded correctly
availableAPIs.specific = xpcall(loadSpecificAPIs, debug.traceback) -- TRUE if all specific APIs were loaded correctly

return availableAPIs
--**************************************************************************