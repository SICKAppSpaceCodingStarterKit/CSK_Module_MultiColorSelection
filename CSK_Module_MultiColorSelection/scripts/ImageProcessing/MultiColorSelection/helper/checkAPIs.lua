---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- Load all relevant APIs for this module
--**************************************************************************

local availableAPIs = {}

local function loadAPIs()

  CSK_MultiColorSelection = require 'API.CSK_MultiColorSelection'

  Container = require 'API.Container'
  DateTime = require 'API.DateTime'
  Engine = require 'API.Engine'
  Image = require 'API.Image'
  Image.PixelRegion = require 'API.Image.PixelRegion'
  Log = require 'API.Log'
  Log.Handler = require 'API.Log.Handler'
  Log.SharedLogger = require 'API.Log.SharedLogger'
  Object = require 'API.Object'
  Point = require 'API.Point'
  Shape = require 'API.Shape'
  Shape.Composite = require 'API.Shape.Composite'
  Timer = require 'API.Timer'
  View = require 'API.View'
  View.PixelRegionDecoration = require 'API.View.PixelRegionDecoration'
  View.ShapeDecoration = require 'API.View.ShapeDecoration'

  -- Check if related CSK modules are available to be used
  local appList = Engine.listApps()
  for i = 1, #appList do
    if appList[i] == 'CSK_Module_PersistentData' then
      CSK_PersistentData = require 'API.CSK_PersistentData'
    elseif appList[i] == 'CSK_Module_UserManagement' then
      CSK_UserManagement = require 'API.CSK_UserManagement'
    end
  end
end

availableAPIs.default = xpcall(loadAPIs, debug.traceback) -- TRUE if all default APIs were loaded correctly

return availableAPIs
--**************************************************************************