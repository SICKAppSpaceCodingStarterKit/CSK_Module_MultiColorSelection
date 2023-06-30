---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- Decorations for visualization
------------------------------------------------------------------
local decos = {}

local shapeDeco = {}

local decorationOK = View.ShapeDecoration.create()
decorationOK:setFillColor(0, 127, 195, 50)
decorationOK:setLineWidth(3)
decos.decorationOK = decorationOK

local decoPixelRegionGood = View.PixelRegionDecoration.create()
decoPixelRegionGood:setColor(0, 255, 0, 100)
decos.decoPixelRegionGood = decoPixelRegionGood

local decoPixelRegionBad = View.PixelRegionDecoration.create()
decoPixelRegionBad:setColor(255, 0, 0, 100)
decos.decoPixelRegionBad = decoPixelRegionBad

local decoPixelRegionGreen = View.PixelRegionDecoration.create()
decoPixelRegionGreen:setColor(0, 255, 0, 255)
decos.decoPixelRegionGreen = decoPixelRegionGreen

local decorationNoROI = View.PixelRegionDecoration.create()
decorationNoROI:setColor(255, 255, 255, 50)
decos.decorationNoROI = decorationNoROI

local decorationMasking = View.PixelRegionDecoration.create()
decorationMasking:setColor(100, 0, 0, 150)
decos.decorationMasking = decorationMasking

-- Hue value 166-180 & 1-15
local shapeDecoRed = View.ShapeDecoration.create()
shapeDecoRed:setLineColor(255, 0, 0)
shapeDecoRed:setLineWidth(8)
-- Hue value 15-25
local shapeDecoOrange = View.ShapeDecoration.create()
shapeDecoOrange:setLineColor(255, 165, 0)
shapeDecoOrange:setLineWidth(8)
-- Hue value 26-39
local shapeDecoYellow = View.ShapeDecoration.create()
shapeDecoYellow:setLineColor(255, 255, 0)
shapeDecoYellow:setLineWidth(8)
-- Hue value 40-69
local shapeDecoGreen = View.ShapeDecoration.create()
shapeDecoGreen:setLineColor(0, 255, 0)
shapeDecoGreen:setLineWidth(8)
decos.shapeDecoGreen = shapeDecoGreen
-- Hue value 70-99
local shapeDecoCyan = View.ShapeDecoration.create()
shapeDecoCyan:setLineColor(0, 255, 255)
shapeDecoCyan:setLineWidth(8)
-- Hue value 100-135
local shapeDecoBlue = View.ShapeDecoration.create()
shapeDecoBlue:setLineColor(0, 0, 255)
shapeDecoBlue:setLineWidth(8)
-- Hue value 136-165
local shapeDecoPurple = View.ShapeDecoration.create()
shapeDecoPurple:setLineColor(255, 0, 255)
shapeDecoPurple:setLineWidth(8)

-- Decos used for colored Shapes in result image
table.insert(shapeDeco, 1, shapeDecoRed)
table.insert(shapeDeco, 2, shapeDecoOrange)
table.insert(shapeDeco, 3, shapeDecoYellow)
table.insert(shapeDeco, 4, shapeDecoGreen)
table.insert(shapeDeco, 5, shapeDecoCyan)
table.insert(shapeDeco, 6, shapeDecoBlue)
table.insert(shapeDeco, 7, shapeDecoPurple)

decos.shapeDeco = shapeDeco

------------------------------------------------------------------

return decos