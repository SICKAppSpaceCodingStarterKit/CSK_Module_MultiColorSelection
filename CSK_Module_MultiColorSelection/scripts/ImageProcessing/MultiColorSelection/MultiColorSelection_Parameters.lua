---@diagnostic disable: redundant-parameter, undefined-global

--***************************************************************
-- Inside of this script, you will find the relevant parameters
-- for this module and its default values
--***************************************************************

local functions = {}

local function getParameters()

  local multiColorSelection = {}

  multiColorSelection.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  multiColorSelection.registeredEvent = '' -- Event to register to get images to process
  multiColorSelection.processingFile = 'CSK_MultiColorSelection_Processing' -- Script to use for processing in thread

  multiColorSelection.showImageChannel = 'Value' -- Image to show in UI viewer (Hue, Saturation, Value)
  multiColorSelection.showAOI = false -- Show area of interest within image in UI viewer
  multiColorSelection.showImage = true -- Show image in UI viewer
  multiColorSelection.maxImageQueueSize = 5 -- Max size of queue. If bigger, images will not be processed

  -- Type of result output
  multiColorSelection.resultOutput = 'TOTAL+SUBRESULTS' -- 'TOTAL', 'TOTAL+SUBRESULTS', 'TOTAL+SUBVALUES'

  multiColorSelection.preFilterAOIActive = false -- Prefilter area of interest active
  multiColorSelection.preFilterAOIChannel = 'Saturation' -- Image channel to use for prefilter AOI
  multiColorSelection.preFilterAOIMin = 60 -- Min value to consider as AOI
  multiColorSelection.preFilterAOIMax = 255 -- Max value to consider as AOI

  multiColorSelection.preFilterAONIActive = false -- Prefilter area of NON interest active
  multiColorSelection.preFilterAONIChannel = 'Value' -- Image channel to use for prefilter AONI
  multiColorSelection.preFilterAONIMin = 0 -- Min value to consider as AONI
  multiColorSelection.preFilterAONIMax = 30 -- Max value to consider as AONI

  multiColorSelection.colorObjects = {} -- table to hold object configuration

  for i = 1, 12 do
    local obj = {}

    obj.objectName = 'Object' .. tostring(i) -- name of the object
    obj.colorActive = false  -- is this object active
    obj.colorMode = 'Color' -- 1 = Color, 2 = Grayvalue
    obj.colorValue = 1 -- color-value of the object
    obj.regionColor = 1 -- color of the ROI in result image
    obj.colorTolerance = 0 -- tolerance of the object
    obj.minBlobSize = 100 -- minimum blob size
    obj.maxBlobSize = 10000 -- maximum blob size
    obj.pixelRefactorActive = false -- Refactor px/mm active
    obj.pixelRefactorUnit = 'px' -- 'px/mm' or 'px'
    obj.pixelRefactor = 1.0 -- Refactor px/mm
    obj.pixelRefactorUseable = obj.pixelRefactor*obj.pixelRefactor -- calculated pixel refactor
    obj.minGood = 1 -- minimum accepted amount of found objects
    obj.maxGood = 1 -- maximum accepted amount of found objects

    obj.type_ROI = 'Rectangle' -- type of ROI, 'Rectangle' / 'Circle'
    obj.centerX_ROI = 100.0 -- xPos of ROI
    obj.centerY_ROI = 100.0 -- yPos of ROI
    obj.radius_ROI = 100.0 -- radius of ROI if circle
    obj.width_ROI = 100.0 -- width of ROI
    obj.height_ROI = 100.0 -- height of ROI
    obj.center_ROI = Point.create(obj.centerX_ROI, obj.centerY_ROI) -- centerPoint of ROI
    obj.ROI = Shape.createRectangle(obj.center_ROI, obj.width_ROI, obj.height_ROI) -- ROI itself
    obj.roiActive = false -- is ROI active

    obj.type_maskingROI = 'Rectangle' -- type of masks, 'Rectangle' / 'Circle'
    obj.maskingROIActive = false -- is maskingROI active

    obj.maskingROIs = {} -- table of masks to not consider within image

    local mask = {} -- single mask
    local maskCP = Point.create(100.0, 100-0) -- centerPoint of maskingROI
    mask.mask = Shape.createRectangle(maskCP, 100.0, 100.0) -- mask itself

    table.insert(obj.maskingROIs, mask)

    obj.maskingROIComposite = Shape.Composite.create() -- Composite of all masks together
    Shape.Composite.addShape(obj.maskingROIComposite, mask.mask)

    table.insert(multiColorSelection.colorObjects, obj)

  end

  return multiColorSelection
end
functions.getParameters = getParameters

return functions