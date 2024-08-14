---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

local nameOfModule = 'CSK_MultiColorSelection'

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
local availableAPIs = require('ImageProcessing/MultiColorSelection/helper/checkAPIs') -- can be used to adjust function scope of the module related on available APIs of the device
-----------------------------------------------------------
-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')

-- Load helper funcs
local decos = require('ImageProcessing/MultiColorSelection/helper/deco')
local helperFuncs = require('ImageProcessing/MultiColorSelection/helper/funcs')

local scriptParams = Script.getStartArgument() -- Get parameters from model

local multiColorSelectionInstanceNumber = scriptParams:get('multiColorSelectionInstanceNumber') -- number of this instance
local multiColorSelectionInstanceNumberString = tostring(multiColorSelectionInstanceNumber) -- number of this instance as string

local viewerID = scriptParams:get('viewerID')
local viewer = View.create(viewerID) --> if needed
local latestImage = nil -- holds image to post process e.g. after changing parameters

local imageQueue = Script.Queue.create() -- Queue to stop processing if increasing too much
local lastQueueSize = nil -- Size of queue
local endResult -- End result of internal processing

local gotImageSize = false -- Was image size already detected
local imageSizeX, imageSizeY -- size x,y of image
local pixelSizeX, pixelSizeY -- size of pixel
local fullPixelRegion -- Pixel region of full image

local imageID = 'Image' -- image ID for viewer
local roiID = 'ROI' -- ID of ROI in viewer
local roiEditorActive = false -- is ROI editor in viewer active
local maskingROIID = 'maskingROI' -- ID of masking ROI in viewer
local maskingROIEditorActive = false -- is masking editor in viewer active
local pipetteID = 'Pipette' -- ID of pipette ROI in viewer
local pipetteROI -- Shape of pipette
local tempPipetteROI -- temporarly Shape of pipette
local pipetteActive = false -- -- is pipette editor /mode in viewer active
local checkColorOfROI = false -- check content of pipette to get color value
local installedEditorIconic = nil -- is editor in viewer installed on an object like pipette, ROI, mask
local currentMaskingROIID = 1 -- ID of selected mask (multi masks are possible)

-- Event to notify result of processing
Script.serveEvent("CSK_MultiColorSelection.OnNewResult" .. multiColorSelectionInstanceNumberString, "MultiColorSelection_OnNewResult" .. multiColorSelectionInstanceNumberString, 'bool:1, string:?, int:?')
-- Event to notify result of processing as string
Script.serveEvent("CSK_MultiColorSelection.OnNewStringResult" .. multiColorSelectionInstanceNumberString, "MultiColorSelection_OnNewStringResult" .. multiColorSelectionInstanceNumberString, 'string:1')
-- Event to forward updated values e.g. through Controler to UI
Script.serveEvent("CSK_MultiColorSelection.OnNewValueToForward".. multiColorSelectionInstanceNumberString, "MultiColorSelection_OnNewValueToForward" .. multiColorSelectionInstanceNumberString, 'string:1, auto:1')
-- Event to sync internally updated values with Controller values
Script.serveEvent("CSK_MultiColorSelection.OnNewValueUpdate" .. multiColorSelectionInstanceNumberString, "MultiColorSelection_OnNewValueUpdate" .. multiColorSelectionInstanceNumberString, 'int:1, string:1, auto:1, int:?')

local processingParams = {}
processingParams.selectedStep = '1' -- Current selected processing step (1-5)
processingParams.activeInUI = false -- Is current instance active within UI, e.g. to update values on UI of this instance
processingParams.selectedColorObject = 1 -- Currently selected color object

local function handleOnNewProcessing(image, timestamp)
  --print("Received after =".. tostring(DateTime.getTimestamp()-timestamp)) -- For debugging only

  -- Check size of queue
  local imageQueueSize = imageQueue:getSize()
  if processingParams.activeInUI == true and imageQueueSize ~= lastQueueSize then
      Script.notifyEvent('MultiColorSelection_OnNewValueToForward' .. multiColorSelectionInstanceNumberString, 'MultiColorSelection_OnNewImageQueue', tostring(imageQueueSize))
      lastQueueSize = imageQueueSize
  end

  if imageQueueSize >= processingParams.maxImageQueueSize then
    _G.logger:warning(nameOfModule .. ": Warning! ImageQueue of instance " .. multiColorSelectionInstanceNumberString .. "is >= " .. tostring(processingParams.maxImageQueueSize) .. "! Stop processing images! Data loss possible...")
  else

    ------------- START COLOR PROCESSING -------------

    --Get size of Image if not already got
    if gotImageSize == false then
      imageSizeX, imageSizeY = Image.getSize(image)
      pixelSizeX, pixelSizeY = Image.getPixelSize(image)

      gotImageSize = true

      -- Recalculate size of ROIs
      fullPixelRegion = Image.PixelRegion.createRectangle(0, 0, imageSizeX-1, imageSizeY-1)
      local centerPoint = Point.create((Image.getWidth(image)/2), (Image.getHeight(image)/2))
      pipetteROI  = Shape.createRectangle(centerPoint, (Image.getWidth(image)/10), (Image.getHeight(image)/10))
      tempPipetteROI  = Shape.createRectangle(centerPoint, (Image.getWidth(image)/10), (Image.getHeight(image)/10))

    end

    local tic = DateTime.getTimestamp()

    _G.logger:fine(nameOfModule .. ": Check image on instance No." .. multiColorSelectionInstanceNumberString)

    if processingParams.selectedStep ~= '5' or latestImage == nil then
      latestImage = image
    end

    -- Separate image in Hue, Saturation, Value images
    local images = {}
    images['Hue'], images['Saturation'], images['Value'] = image:toHSV()

    -- This is just a workaround because of a bug inside of the later used threshold function.
    -- Should maybe deleted with later AppEngine versions...
    local imageH_pad = images['Hue']:pad(0, 0, 0, 1, "CONSTANT", 0)
    local imageV_pad = images['Value']:pad(0, 0, 0, 1, "CONSTANT", 0)

    if pipetteActive == true then
      -- If pipette is activated in UI
      if installedEditorIconic == nil then
        viewer:clear()
        local parentID
        if processingParams.colorObjects[processingParams.selectedColorObject]["colorMode"] == 'Color' then
          parentID = viewer:addImage(image, nil, imageID)
        else
          parentID = viewer:addImage(images['Value'], nil, imageID)
        end
        viewer:addShape(pipetteROI, decos.decorationOK, pipetteID, parentID)
        viewer:installEditor(pipetteID)
        installedEditorIconic = pipetteID
        viewer:present()
      end
      return
    end

    -- Get and set value of color / gray value pipette for actual color if just configured
    if checkColorOfROI == true then
      local meanHueValue, min, max, mean, selectedImage
      if processingParams.colorObjects[processingParams.selectedColorObject]["colorMode"] == 'Color' then
        selectedImage = images['Hue']  -- if working on color image
      else
        selectedImage = images['Value'] -- if working on gray value image
      end

      -- Get mean value of selected region
      local pixelRegionPipette = Shape.toPixelRegion(tempPipetteROI, selectedImage)
      if not Image.PixelRegion.isEmpty(pixelRegionPipette) then
        min, max, meanHueValue = Image.PixelRegion.getStatistics(Shape.toPixelRegion(tempPipetteROI, selectedImage), selectedImage)

        -- Check if mean value could be determined correctly, because values of "red" can be both high and low (eg. "2" and "178")
        --> leading to wrong mean values.
        if min < 10 and max > 160 and processingParams.colorObjects[processingParams.selectedColorObject]["colorMode"] == 'Color' then
          mean = 1
        else
          mean = math.floor(meanHueValue)
        end
      else
        mean = 0

      end

      -- Set selected color value to job parameters
      processingParams.colorObjects[processingParams.selectedColorObject]["colorValue"] = mean

      local regionColor = helperFuncs.selectRegionColor(mean)
      processingParams.colorObjects[processingParams.selectedColorObject]["regionColor"] = regionColor

      Script.notifyEvent("MultiColorSelection_OnNewValueUpdate" .. multiColorSelectionInstanceNumberString, multiColorSelectionInstanceNumber, 'colorValue', mean, processingParams.selectedColorObject)
      Script.notifyEvent("MultiColorSelection_OnNewValueUpdate" .. multiColorSelectionInstanceNumberString, multiColorSelectionInstanceNumber, 'regionColor', regionColor, processingParams.selectedColorObject)
      checkColorOfROI = false
      Script.notifyEvent("MultiColorSelection_OnNewValueToForward" .. multiColorSelectionInstanceNumberString, 'MultiColorSelection_OnNewColorValue', mean)
    end

    -- Set ROI for actual color if just configured
    if roiEditorActive == true then
      if installedEditorIconic == nil then
        viewer:clear()
        local parentID = viewer:addImage(image, nil, imageID)
        viewer:addShape(processingParams.colorObjects[processingParams.selectedColorObject]["ROI"], decos.decorationOK, roiID, parentID)
        viewer:installEditor(roiID)
        installedEditorIconic = roiID
        viewer:present()
      end
      return
    end

    -- Set Masking ROI for actual color if just configured
    if maskingROIEditorActive == true then
      if installedEditorIconic == nil then
        viewer:clear()
        local parentID = viewer:addImage(image, nil, imageID)

        for i=1, #processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"] do
          viewer:addShape(processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"][i]["mask"], decos.decorationOK, maskingROIID .. tostring(i), parentID)
        end
        currentMaskingROIID = #processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"]

        viewer:installEditor(maskingROIID .. tostring(currentMaskingROIID))
        installedEditorIconic = maskingROIID .. tostring(currentMaskingROIID)
        viewer:present()
      end
      return
    end

    local preFilterAOI
    if processingParams.preFilterAOIActive then
      -- Threshold on selected image to find area of interest (all objects)
      preFilterAOI = images[processingParams.preFilterAOIChannel]:threshold(processingParams.preFilterAOIMin,processingParams.preFilterAOIMax)
    end

    if processingParams.selectedStep == '1' and processingParams.showImage then
      viewer:clear()
      local parentID = viewer:addImage(images[processingParams.preFilterAOIChannel], nil, imageID)
      if processingParams.preFilterAOIActive then
        viewer:addPixelRegion(preFilterAOI, decos.decoPixelRegionGood, nil, parentID)
      end
      viewer:present()
      return
    end

    -- Threshold on selected image to differentiate between area of interest and area of non interest
    local prefilterAONI

    if processingParams.preFilterAONIActive then
      prefilterAONI = images[processingParams.preFilterAONIChannel]:threshold(processingParams.preFilterAONIMin, processingParams.preFilterAONIMax)
    else
      prefilterAONI = fullPixelRegion
    end

    if processingParams.selectedStep == '2' and processingParams.showImage then
      -- If selected "Step2" on "Object Definition" page, function can leave after showing actual content
      viewer:clear()
      local parentID = viewer:addImage(images[processingParams.preFilterAONIChannel], nil, imageID)
      if processingParams.preFilterAONIActive then
        viewer:addPixelRegion(prefilterAONI, decos.decoPixelRegionBad, nil, parentID)
      end
      viewer:present()
      return
    end

    local preFilterBase
    if processingParams.preFilterAOIActive and processingParams.preFilterAONIActive then
      -- Reduce Image just to colored Items
      preFilterBase = Image.PixelRegion.getDifference(preFilterAOI, prefilterAONI)
    elseif processingParams.preFilterAOIActive then
      preFilterBase = preFilterAOI
    elseif processingParams.preFilterAONIActive == true then
      preFilterBase = Image.PixelRegion.getDifference(fullPixelRegion, prefilterAONI)
    else
      preFilterBase = fullPixelRegion
    end

    if processingParams.selectedStep == '3' and processingParams.showImage then
      -- If selected "Step3" on "Object Definition" page, function can leave after showing actual content
      viewer:clear()
      local parentID = viewer:addImage(images[processingParams.showImageChannel], nil, imageID)
      if processingParams.showAOI then
        viewer:addPixelRegion(preFilterBase, decos.decoPixelRegionGreen, nil, parentID)
      end
      viewer:present()
      return
    end

    endResult = true
    local parentID

    if processingParams.selectedStep == '5' and processingParams.showImage then
      viewer:clear()
      parentID = viewer:addImage(image, nil, imageID)
    end

    local start = 1
    local k = 12

    -- Check if in Color Setup Mode (only 1 color to check) or Run Mode (check all active colors)
    if processingParams.selectedStep == '4' then
      start = processingParams.selectedColorObject
      k = processingParams.selectedColorObject
    end

    local objCounter = {}
    local results = {}

    -- Check all active colors or just the selected color (depends on which UI-page is currently active)
    for i = start, k do
      local blobsCnt = 0
      local blobMax = 0
      local blobMin = 0
      local preFilter

      if processingParams.colorObjects[i]["colorActive"] == true then
        if processingParams.colorObjects[i]["roiActive"] == true then
          -- Reduce just to specified region of image
          preFilter = Image.PixelRegion.getIntersection(preFilterBase, Shape.toPixelRegion(processingParams.colorObjects[i]["ROI"], images['Value']))
        else
          -- Use complete image
          preFilter = preFilterBase
        end

        if processingParams.colorObjects[i]["maskingROIActive"] == true then
          -- Reduce just to specified region of image
          if #processingParams.colorObjects[i]["maskingROIs"] > 1 then
            preFilter = Image.PixelRegion.getDifference(preFilter, Shape.Composite.toPixelRegion(processingParams.colorObjects[i]["maskingROIComposite"], images['Value']))
          else
            preFilter = Image.PixelRegion.getDifference(preFilter, Shape.toPixelRegion(processingParams.colorObjects[i]["maskingROIs"][1]["mask"], images['Value']))
          end
        end

        -- Find pixels with specified color value
        local colorRegion = Image.PixelRegion.createEmpty()
        local colorRegionAdditional

        if processingParams.colorObjects[i]["colorMode"] == 'Color' and preFilter:isEmpty() == false then
          -- Use color information
          -- Because color "red" can include low AND high values, check if it is necessary to search for blobs in both ranges

          -- INFO
          -- The reason to use the 'imageXpad' images is just a workaround because of a bug inside of the used threshold function.
          -- Should maybe deleted with later AppEngine versions... (> AE 2.13)

          if processingParams.colorObjects[i]["colorValue"]-processingParams.colorObjects[i]["colorTolerance"] < 0 then
            colorRegion = imageH_pad:threshold(0, processingParams.colorObjects[i]["colorValue"]+processingParams.colorObjects[i]["colorTolerance"], preFilter)
            colorRegionAdditional = imageH_pad:threshold(180+(processingParams.colorObjects[i]["colorValue"]-processingParams.colorObjects[i]["colorTolerance"]), 180, preFilter)
            colorRegion = Image.PixelRegion.getUnion(colorRegion, colorRegionAdditional)
          elseif processingParams.colorObjects[i]["colorValue"]-processingParams.colorObjects[i]["colorTolerance"] == 0 then
            colorRegion = imageH_pad:threshold(0, processingParams.colorObjects[i]["colorValue"]+processingParams.colorObjects[i]["colorTolerance"], preFilter)
          elseif processingParams.colorObjects[i]["colorValue"]+processingParams.colorObjects[i]["colorTolerance"] > 180 then
            colorRegion = imageH_pad:threshold(processingParams.colorObjects[i]["colorValue"]-processingParams.colorObjects[i]["colorTolerance"], 180, preFilter)
            colorRegionAdditional = imageH_pad:threshold(0, (processingParams.colorObjects[i]["colorValue"]+processingParams.colorObjects[i]["colorTolerance"])-180, preFilter)
            colorRegion = Image.PixelRegion.getUnion(colorRegion, colorRegionAdditional)
          else
            colorRegion = imageH_pad:threshold(processingParams.colorObjects[i]["colorValue"]-processingParams.colorObjects[i]["colorTolerance"], processingParams.colorObjects[i]["colorValue"]+processingParams.colorObjects[i]["colorTolerance"], preFilter)
          end

        elseif processingParams.colorObjects[i]["colorMode"] == 'Grey' and preFilter:isEmpty() == false then
          -- Use gray value information
          colorRegion = imageV_pad:threshold(processingParams.colorObjects[i]["colorValue"]-processingParams.colorObjects[i]["colorTolerance"], processingParams.colorObjects[i]["colorValue"]+processingParams.colorObjects[i]["colorTolerance"], preFilter)
        end

        local blobs
        -- Only select areas with connected color-pixels
        if processingParams.colorObjects[i]["pixelRefactorActive"] then
          -- recalculate given size in mm² to px
          blobs = colorRegion:findConnected(processingParams.colorObjects[i]["minBlobSize"]*processingParams.colorObjects[i]["pixelRefactorUseable"], processingParams.colorObjects[i]["maxBlobSize"]*processingParams.colorObjects[i]["pixelRefactorUseable"])
        else
          blobs = colorRegion:findConnected(processingParams.colorObjects[i]["minBlobSize"], processingParams.colorObjects[i]["maxBlobSize"])
        end

        -- Check number, min and max size of blobs
        if #blobs ~= 0 then
          if processingParams.colorObjects[i]["pixelRefactorActive"] then
            -- recalculate given size in mm² to px
            blobMax = blobs[1]:countPixels()/processingParams.colorObjects[i]["pixelRefactorUseable"]
            blobMin = blobs[#blobs]:countPixels()/processingParams.colorObjects[i]["pixelRefactorUseable"]
          else
            blobMax = blobs[1]:countPixels()
            blobMin = blobs[#blobs]:countPixels()
          end
          blobsCnt = #blobs
        end

        -- Decide if counted blobs are in acceptable range and store sub-result
        if blobsCnt >= processingParams.colorObjects[i]["minGood"] and blobsCnt <= processingParams.colorObjects[i]["maxGood"] then
          table.insert(results, true)
        else
          table.insert(results, false)
        end
        table.insert(objCounter, blobsCnt)

        -- If Color Setup Viewer is active (in Step4) show image and found objects in UI
        if processingParams.selectedStep == '4' and processingParams.showImage then -- and gColorSelecterActive == true then
          viewer:clear()
          if processingParams.colorObjects[processingParams.selectedColorObject]["colorMode"] == 'Color' then
            parentID = viewer:addImage(image, nil, imageID)
          else
            parentID = viewer:addImage(images['Value'], nil, imageID)
          end

          if colorRegion:isEmpty() == false then
            viewer:addPixelRegion(colorRegion, decos.decoPixelRegionGreen, nil, parentID)
          end

          if #blobs ~= 0 then
            for j = 1, #blobs do
              local boundingBox = blobs[j]:getBoundingBox(image)
              viewer:addShape(boundingBox, decos.shapeDecoGreen, nil, parentID)
            end
          end

          if processingParams.colorObjects[i]["maskingROIActive"] == true then
            if #processingParams.colorObjects[i]["maskingROIs"] > 1 then
              viewer:addPixelRegion(Shape.Composite.toPixelRegion(processingParams.colorObjects[i]["maskingROIComposite"], images['Value']), decos.decorationMasking, nil, parentID)
            else
              viewer:addPixelRegion(Shape.toPixelRegion(processingParams.colorObjects[i]["maskingROIs"][1]["mask"], images['Value']), decos.decorationMasking, nil, parentID)
            end
          end
          if processingParams.colorObjects[i]["roiActive"] == true then
            viewer:addPixelRegion(Shape.toPixelRegion(processingParams.colorObjects[i]["ROI"], images['Value']), decos.decorationNoROI, nil, parentID)
          end

          viewer:present()

          Script.notifyEvent("MultiColorSelection_OnNewValueToForward" .. multiColorSelectionInstanceNumberString, 'MultiColorSelection_OnNewFoundBlobs', tostring(#blobs))
          Script.notifyEvent("MultiColorSelection_OnNewValueToForward" .. multiColorSelectionInstanceNumberString, 'MultiColorSelection_OnNewSizeSmallestBlob', string.format("%.1f",(blobMin)))
          Script.notifyEvent("MultiColorSelection_OnNewValueToForward" .. multiColorSelectionInstanceNumberString, 'MultiColorSelection_OnNewSizeBiggestBlob', string.format("%.1f",(blobMax)))

          return
        end

        -- If Result Viewer is active, create shapes for found objects
        if processingParams.selectedStep == '5' and processingParams.showImage then
          for j = 1, #blobs do
            local boundingBox = blobs[j]:getBoundingBox(image)
            viewer:addShape(boundingBox, decos.shapeDeco[processingParams.colorObjects[i]["regionColor"]], "blob"..tostring(i)..tostring(j), parentID)
          end
        end

        -- Use sub-result for overall result
        endResult = results[#results] and endResult
      end
    end

    if processingParams.selectedStep == '5' and processingParams.showImage then
      viewer:present()
    end

    local resultString = nil
    if processingParams.resultOutput == 'TOTAL+SUBRESULTS' then
      -- Single Results + End Result
      if #results >= 1 then
        resultString = tostring(results[1])
        for i=2, #results do
          resultString = resultString .. "," .. tostring(results[i])
        end
      end

    elseif processingParams.resultOutput == 'TOTAL+SUBVALUES' then
      -- Single Values + End Result
      if #objCounter >= 1 then
        resultString = tostring(objCounter[1])
        for i=2, #objCounter do
          resultString = resultString .. "," .. tostring(objCounter[i])
        end
      end
    end

    --if timestamp then
      --print("Needed time till result available =" .. tostring(DateTime.getTimestamp()-timestamp))  -- For debugging only
    --end
    Script.notifyEvent('MultiColorSelection_OnNewResult'.. multiColorSelectionInstanceNumberString, endResult, resultString, timestamp)
    Script.notifyEvent('MultiColorSelection_OnNewStringResult'.. multiColorSelectionInstanceNumberString, tostring(endResult) .. ';' .. tostring(resultString) .. ';' .. tostring(timestamp))

    if processingParams['activeInUI'] then
      Script.notifyEvent("MultiColorSelection_OnNewValueToForward" .. multiColorSelectionInstanceNumberString, 'MultiColorSelection_OnNewProcessingTime', tostring(DateTime.getTimestamp()-tic))
      Script.notifyEvent("MultiColorSelection_OnNewValueToForward" .. multiColorSelectionInstanceNumberString, 'MultiColorSelection_OnNewTotalResult', endResult)
      if not resultString then
        resultString = '-'
      end
      Script.notifyEvent("MultiColorSelection_OnNewValueToForward" .. multiColorSelectionInstanceNumberString, 'MultiColorSelection_OnNewResult', resultString)
    end
  end
end
Script.serveFunction("CSK_MultiColorSelection.processInstance"..multiColorSelectionInstanceNumberString, handleOnNewProcessing, 'object:1:Image', 'bool:?')

--- Function to set event to register
---@param event string Name of event
local function setRegisterEvent(event)
  _G.logger:fine(nameOfModule .. ": Register instance " .. multiColorSelectionInstanceNumberString .. " on event " .. event)
  if processingParams.registeredEvent and processingParams.registeredEvent ~= '' then
    Script.deregister(processingParams.registeredEvent, handleOnNewProcessing)
    imageQueue:clear()
  end
  processingParams.registeredEvent = event
  Script.register(event, handleOnNewProcessing)
  imageQueue:setFunction(handleOnNewProcessing)
  gotImageSize = false
end

--- Function to deregister from event
local function deregisterFromEvent()
  _G.logger:fine(nameOfModule .. ": Deregister instance " .. multiColorSelectionInstanceNumberString .. " from event.")
  Script.deregister(processingParams.registeredEvent, handleOnNewProcessing)
  processingParams.registeredEvent = ''
  imageQueue:clear()
end

--- Function to set all processing parameters
---@param paramContainer Container Processing parameters
local function setAllProcessingParameters(paramContainer)
  local tempEvent = paramContainer:get('registeredEvent')

  setRegisterEvent(tempEvent)

  processingParams.maxImageQueueSize = paramContainer:get('maxImageQueueSize')
  processingParams.showImage = paramContainer:get('showImage')

  processingParams.preFilterAOIActive = paramContainer:get('preFilterAOIActive')
  processingParams.preFilterAOIChannel = paramContainer:get('preFilterAOIChannel')
  processingParams.preFilterAOIMin = paramContainer:get('preFilterAOIMin')
  processingParams.preFilterAOIMax = paramContainer:get('preFilterAOIMax')

  processingParams.preFilterAONIActive = paramContainer:get('preFilterAONIActive')
  processingParams.preFilterAONIChannel = paramContainer:get('preFilterAONIChannel')
  processingParams.preFilterAONIMin = paramContainer:get('preFilterAONIMin')
  processingParams.preFilterAONIMax = paramContainer:get('preFilterAONIMax')

  processingParams.showImageChannel = paramContainer:get('showImageChannel')
  processingParams.showAOI = paramContainer:get('showAOI')
  processingParams.resultOutput = paramContainer:get('resultOutput')

  processingParams.colorObjects = helperFuncs.convertContainer2Table(paramContainer:get('colorObjects'))

end

setAllProcessingParameters(scriptParams)

---------------------------------------------------

--**********************************
-- Region of Interest Functions
--**********************************
--- Function to react on selected ROI within viewer
---@param iconicID string The ID of the iconic under the pointer or an empty string if no iconic was hit.
---@param pointerActionType View.PointerActionType Pointer action type
---@param pointerType View.PointerType Pointer type
local function handleOnPointerEditor(iconicID, pointerActionType, pointerType)
  if pointerType == 'PRIMARY' and pointerActionType == 'CLICKED' then
    if installedEditorIconic == iconicID then

      -- Nothing to do, editor is already installed on selected ID
      return

    -- Installing editor on the rectangle if selected in the viewer
    elseif iconicID == roiID or iconicID == pipetteID then
      if installedEditorIconic then
        viewer:uninstallEditor(installedEditorIconic)
      end

      viewer:installEditor(iconicID)
      installedEditorIconic = iconicID

    elseif string.sub(iconicID, 1, #iconicID-1) == maskingROIID then
      currentMaskingROIID = tonumber(string.sub(iconicID, #iconicID, #iconicID))
      if installedEditorIconic then
        viewer:uninstallEditor(installedEditorIconic)
      end

      viewer:installEditor(iconicID)
      installedEditorIconic = iconicID
    elseif iconicID == pipetteID then
      viewer:installEditor(iconicID)
      installedEditorIconic = iconicID
    end
    viewer:present()
  end
end
View.register(viewer, "OnPointer", handleOnPointerEditor)

--- Function to call if the installed editor detects changes of the iconic in the viewer
---@param iconicID string ID of the modified iconic
---@param iconic object The modified iconic
local function handleOnChangeEditor(iconicID, iconic)

  -- Checking if selected iconic is the added rectangle
  if iconicID == roiID then
    -- Updating rectangle in script with the one defined in the viewer
    processingParams.colorObjects[processingParams.selectedColorObject]["ROI"] = iconic

  ---------------------------------------------
  elseif string.sub(iconicID, 1, #iconicID-1) == maskingROIID then
    -- Updating mask in script with the one defined in the viewer
    processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"][currentMaskingROIID]["mask"] = iconic

    if #processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"] >= 2 then
      processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIComposite"] = Shape.Composite.create()
      for i = 1, #processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"] do
        Shape.Composite.addShape(processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIComposite"], processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"][i]["mask"])
      end
    end

  elseif iconicID == pipetteID then
    tempPipetteROI = iconic
  end
end
View.register(viewer, 'OnChange', handleOnChangeEditor)

---------------------------------------------------

--- Function to handle updates of processing parameters from Controller
---@param multiColorSelectionNo int Number of instance to update
---@param parameter string Parameter to update
---@param value auto Value of parameter to update
---@param colorObject int? Number of object
local function handleOnNewProcessingParameter(multiColorSelectionNo, parameter, value, colorObject)

  if multiColorSelectionNo == multiColorSelectionInstanceNumber then -- set parameter only in selected script
    if colorObject then
      _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiColorInstanceNo." .. tostring(multiColorSelectionNo) .. " of colorObject No." .. tostring(colorObject) .. " to value = " .. tostring(value))
        processingParams.colorObjects[colorObject][parameter] = value
    elseif parameter == 'FullSetup' then
      if type(value) == 'userdata' then
        if Object.getType(value) == 'Container' then
            setAllProcessingParameters(value)
        end
      end

    elseif parameter == 'chancelEditors' then
      pipetteActive = false
      roiEditorActive = false
      maskingROIEditorActive = false
      checkColorOfROI = false

    elseif parameter == 'pipetteActive' then
      pipetteActive = value
      if value == true then
        installedEditorIconic = nil
        roiEditorActive = false
        maskingROIEditorActive = false
      else
        checkColorOfROI = true
      end

    elseif parameter == 'roiEditorActive' then
      roiEditorActive = value
      if value == true then
        installedEditorIconic = nil
      else
        Script.notifyEvent("MultiColorSelection_OnNewValueUpdate" .. multiColorSelectionInstanceNumberString, multiColorSelectionInstanceNumber, 'ROI', processingParams.colorObjects[processingParams.selectedColorObject]["ROI"], processingParams.selectedColorObject)
      end

    elseif parameter == 'maskingROIEditorActive' then
      maskingROIEditorActive = value
      if value == true then
        installedEditorIconic = nil
      else
        for i = 1, #processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"] do
          Script.notifyEvent("MultiColorSelection_OnNewValueUpdate" .. multiColorSelectionInstanceNumberString, multiColorSelectionInstanceNumber, 'mask' .. tostring(i), processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"][i]["mask"], processingParams.selectedColorObject)
        end
        Script.notifyEvent("MultiColorSelection_OnNewValueUpdate" .. multiColorSelectionInstanceNumberString, multiColorSelectionInstanceNumber, 'maskingROIComposite', processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIComposite"], processingParams.selectedColorObject)
      end

    elseif parameter == 'resetROI' then
      if installedEditorIconic ~= nil then
        viewer:uninstallEditor(installedEditorIconic)
        installedEditorIconic = nil
      end

      local cP = Point.create((imageSizeX*pixelSizeX)/2, (imageSizeY*pixelSizeY)/2)
      local x, y = Point.getXY(cP)
      local roi  = Shape.createRectangle(cP, imageSizeX*pixelSizeX, imageSizeY*pixelSizeY)

      processingParams.colorObjects[processingParams.selectedColorObject]["ROI"] = roi

      Script.notifyEvent("MultiColorSelection_OnNewValueUpdate" .. multiColorSelectionInstanceNumberString, multiColorSelectionInstanceNumber, 'type_ROI', 'Rectangle', processingParams.selectedColorObject)
      Script.notifyEvent("MultiColorSelection_OnNewValueToForward" .. multiColorSelectionInstanceNumberString, 'MultiColorSelection_OnNewROIType', 'Rectangle')

      viewer:addShape(processingParams.colorObjects[processingParams.selectedColorObject]["ROI"], decos.decorationOK, roiID, nil)
      viewer:installEditor(roiID)
      viewer:present()

    elseif parameter == 'addMaskingROI' then

      if installedEditorIconic ~= nil then
        viewer:uninstallEditor(installedEditorIconic)
        installedEditorIconic = nil
      end

      local tempMask = {}
      local cP = Point.create((imageSizeX*pixelSizeX)/2, (imageSizeY*pixelSizeY)/2)

      if processingParams.colorObjects[processingParams.selectedColorObject]["type_maskingROI"] == 'Rectangle' then
        tempMask.mask = Shape.createRectangle(cP, (imageSizeX*pixelSizeX)/4, (imageSizeX*pixelSizeX)/4) -- ROI itself
      elseif processingParams.colorObjects[processingParams.selectedColorObject]["type_maskingROI"] == 'Circle' then
        tempMask.mask = Shape.createCircle(cP, (imageSizeX*pixelSizeX)/4) -- ROI itself
      end

      table.insert(processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"], tempMask)

      Shape.Composite.addShape(processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIComposite"], tempMask.mask)

    elseif parameter == 'setTypeMaskingROI' then

      if installedEditorIconic ~= nil then
        viewer:uninstallEditor(installedEditorIconic)
        installedEditorIconic = nil
      end

      if processingParams.colorObjects[processingParams.selectedColorObject]["type_maskingROI"] ~= value then

        -- clear all old maskingROIs
        processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIComposite"] = Shape.Composite.create()

        for i=1, #processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"] do
          viewer:remove(maskingROIID .. tostring(i))
          local cp = Shape.getCenterOfGravity(processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"][i]["mask"])

          if value == 'Rectangle' then
            processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"][i]["mask"] = Shape.createRectangle(cp, 100.0, 100.0)
          elseif value == 'Circle' then
            processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"][i]["mask"] = Shape.createCircle(cp, 100.0)
          end
          Shape.Composite.addShape(processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIComposite"], processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"][i]["mask"])

          viewer:addShape(processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"][i]["mask"], decos.decorationOK, maskingROIID .. tostring(i), nil)
        end

        processingParams.colorObjects[processingParams.selectedColorObject]["type_maskingROI"] = value

        viewer:installEditor(maskingROIID .. '1')
        currentMaskingROIID = 1
        viewer:present()
      end

    elseif parameter == 'setTypeROI' then

        if installedEditorIconic ~= nil then
          viewer:uninstallEditor(installedEditorIconic)
          installedEditorIconic = nil
        end

        if value == 'Rectangle' then
          processingParams.colorObjects[processingParams.selectedColorObject]["ROI"] = Shape.createRectangle(processingParams.colorObjects[processingParams.selectedColorObject]["center_ROI"], processingParams.colorObjects[processingParams.selectedColorObject]["width_ROI"], processingParams.colorObjects[processingParams.selectedColorObject]["height_ROI"])
        elseif value == 'Circle' then
          processingParams.colorObjects[processingParams.selectedColorObject]["ROI"] = Shape.createCircle(processingParams.colorObjects[processingParams.selectedColorObject]["center_ROI"], processingParams.colorObjects[processingParams.selectedColorObject]["radius_ROI"])
        end
        viewer:addShape(processingParams.colorObjects[processingParams.selectedColorObject]["ROI"], decos.decorationOK, roiID, nil)
        viewer:installEditor(roiID)
        viewer:present()

    elseif parameter == 'resetMask' then
      if installedEditorIconic ~= nil then
        viewer:uninstallEditor(installedEditorIconic)
        installedEditorIconic = nil
      end

      while #processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"] >= 2 do
        viewer:remove(maskingROIID .. tostring(#processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"]))
        table.remove(processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"], #processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"])
      end
      processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIComposite"] = Shape.Composite.create()

      local cP = Point.create((imageSizeX)/2, (imageSizeY)/2)
      local roi  = Shape.createRectangle(cP, imageSizeX/10, imageSizeY/10)

      processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"][1]["mask"] = roi
      Shape.Composite.addShape(processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIComposite"], roi)

      processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"][1]["type_maskingROI"] = 'Rectangle'

      Script.notifyEvent("MultiColorSelection_OnNewValueUpdate" .. multiColorSelectionInstanceNumberString, multiColorSelectionInstanceNumber, 'type_maskingROI', 'Rectangle', processingParams.selectedColorObject)
      Script.notifyEvent("MultiColorSelection_OnNewValueToForward" .. multiColorSelectionInstanceNumberString, 'MultiColorSelection_OnNewMaskingROIType', 'Rectangle')

      viewer:addShape(processingParams.colorObjects[processingParams.selectedColorObject]["maskingROIs"][1]["mask"], decos.decorationOK, maskingROIID .. '1', nil)
      currentMaskingROIID = 1
      viewer:installEditor(maskingROIID .. '1')
      viewer:present()

    elseif parameter == 'imageSize' then
      gotImageSize = false

    elseif parameter == 'deregisterFromEvent' then
      deregisterFromEvent()

    else
      _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiColorSelectionNo." .. tostring(multiColorSelectionNo) .. " to value = " .. tostring(value))

      if parameter == 'registeredEvent' then
        setRegisterEvent(value)
      else
        processingParams[parameter] = value
      end
    end
  elseif parameter == 'activeInUI' then
    processingParams[parameter] = false
  end

  if processingParams['activeInUI'] and latestImage and imageQueue:getSize() == 0 and gotImageSize == true then -- parameter ~= 'imageSize' then
    handleOnNewProcessing(latestImage)
  end

end
Script.register("CSK_MultiColorSelection.OnNewProcessingParameter", handleOnNewProcessingParameter)
