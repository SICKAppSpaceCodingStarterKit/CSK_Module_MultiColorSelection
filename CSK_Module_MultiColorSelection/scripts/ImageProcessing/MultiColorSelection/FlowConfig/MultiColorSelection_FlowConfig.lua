--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('ImageProcessing.MultiColorSelection.FlowConfig.MultiColorSelection_ImageSource')
require('ImageProcessing.MultiColorSelection.FlowConfig.MultiColorSelection_OnNewResult')
require('ImageProcessing.MultiColorSelection.FlowConfig.MultiColorSelection_Process')

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    CSK_MultiColorSelection.clearFlowConfigRelevantConfiguration()
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)
