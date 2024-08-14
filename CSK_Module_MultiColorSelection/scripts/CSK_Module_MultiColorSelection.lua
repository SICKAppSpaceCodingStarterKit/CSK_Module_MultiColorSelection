--MIT License
--
--Copyright (c) 2023 SICK AG
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
-- If app property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
_G.availableAPIs = require('ImageProcessing/MultiColorSelection/helper/checkAPIs') -- can be used to adjust function scope of the module related on available APIs of the device

-----------------------------------------------------------
-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')
_G.logHandle = Log.Handler.create()
_G.logHandle:attachToSharedLogger('ModuleLogger')
_G.logHandle:setConsoleSinkEnabled(false) --> Set to TRUE if CSK_Logger module is not used
_G.logHandle:setLevel("ALL")
_G.logHandle:applyConfig()
-----------------------------------------------------------

-- Loading script regarding MultiColorSelection_Model
-- Check this script regarding MultiColorSelection_Model parameters and functions
local multiColorSelection_Model = require('ImageProcessing/MultiColorSelection/MultiColorSelection_Model')

local multiColorSelection_Instances = {} -- Handle all instances

-- Load script to communicate with the MultiColorSelection_Model UI
-- Check / edit this script to see/edit functions which communicate with the UI
local multiColorSelectionController = require('ImageProcessing/MultiColorSelection/MultiColorSelection_Controller')

if _G.availableAPIs.default and _G.availableAPIs.specific then
  local setInstanceHandle = require('ImageProcessing/MultiColorSelection/FlowConfig/MultiColorSelection_FlowConfig')
  table.insert(multiColorSelection_Instances, multiColorSelection_Model.create(1))
  multiColorSelectionController.setMultiColorSelection_Instances_Handle(multiColorSelection_Instances)
  setInstanceHandle(multiColorSelection_Instances)
else
  _G.logger:warning("CSK_MultiColorSelection: Relevant CROWN(s) not available on device. Module is not supported...")
end

--**************************************************************************
--**********************End Global Scope ***********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************
--[[
--- Function to show how this module could be used
local function startProcessing()

  --CSK_MultiColorSelection.setInstance(1) --> select instance of module

  -- Option A --> prepare an event to trigger processing via this one
  --Script.serveEvent("CSK_MultiColorSelection.OnNewTestEvent", "MultiColorSelection_OnNewTestEvent") --> Create event to listen to and process forwarded object
  --CSK_MultiColorSelection.setRegisterEvent('CSK_ImagePlayer.OnNewImage') --> Register processing to the event

  --CSK_MultiColorSelection.setInstance(2) --> select instance of module
  --CSK_MultiColorSelection.setRegisterEvent('CSK_ImagePlayer.OnNewImage') --> Register processing to the event

  --Script.notifyEvent('OnNewTestEvent', data)

    -- Option B --> trigger processing via function call
  --local result = CSK_MultiColorSelection.processSomething(data)
end
-- Call processing function after persistent data was loaded
--Script.register("CSK_MultiColorSelection.OnDataLoadedOnReboot", startProcessing)
]]

--- Function to react on startup event of the app
local function main()

  multiColorSelectionController.setMultiColorSelection_Model_Handle(multiColorSelection_Model)

  --table.insert(_G.multiColorSelectionObjects, multiColorSelection_Model.create(2))
  --table.insert(_G.multiColorSelectionObjects, multiColorSelection_Model.create(3))

  ----------------------------------------------------------------------------------------
  -- INFO: Please check if module will eventually load inital configuration triggered via
  --       event CSK_PersistentData.OnInitialDataLoaded
  --       (see internal variable _G.multiColorSelection_Model.parameterLoadOnReboot)
  --       If so, the app will trigger the "OnDataLoadedOnReboot" event if ready after loading parameters
  --
  -- Can be used e.g. like this
  ----------------------------------------------------------------------------------------

  --startProcessing() --> see above
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    CSK_MultiColorSelection.setInstance(1)
  end
  CSK_MultiColorSelection.pageCalled() -- Update UI
end
Script.register("Engine.OnStarted", main)

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************