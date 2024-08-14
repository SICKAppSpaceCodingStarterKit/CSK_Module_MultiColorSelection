--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('ImageProcessing.MultiColorSelection.FlowConfig.MultiColorSelection_ImageSource')
require('ImageProcessing.MultiColorSelection.FlowConfig.MultiColorSelection_OnNewResult')
require('ImageProcessing.MultiColorSelection.FlowConfig.MultiColorSelection_Process')

-- Reference to the multiImageFilter_Instances handle
local multiColorSelection_Instances

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    for i = 1, #multiColorSelection_Instances do
      if multiColorSelection_Instances[i].parameters.flowConfigPriority then
        CSK_MultiColorSelection.clearFlowConfigRelevantConfiguration()
        break
      end
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)

--- Function to get access to the multiColorSelection_Instances
---@param handle handle Handle of multiColorSelection_Instances object
local function setMultiColorSelection_Instances_Handle(handle)
  multiColorSelection_Instances = handle
end

return setMultiColorSelection_Instances_Handle