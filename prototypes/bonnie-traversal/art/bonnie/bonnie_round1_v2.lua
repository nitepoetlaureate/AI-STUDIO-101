-- Round 1 P0+P1: jump_up tag, silhouette rim, Tier A frames, consistent foot baseline.
local root = "/Users/michaelraftery/AI-STUDIO-101/prototypes/bonnie-traversal/art/bonnie/"
local tier = dofile(root .. "_tier_a_grids.lua")

local COL = {
  ["."] = app.pixelColor.rgba(0, 0, 0, 0),
  ["K"] = app.pixelColor.rgba(0, 0, 0, 255),
  ["#"] = app.pixelColor.rgba(42, 38, 36, 255),
  ["d"] = app.pixelColor.rgba(42, 38, 36, 255),
  ["m"] = app.pixelColor.rgba(61, 58, 56, 255),
  ["F"] = app.pixelColor.rgba(244, 236, 216, 255),
  ["E"] = app.pixelColor.rgba(95, 115, 137, 255),
  ["n"] = app.pixelColor.rgba(138, 98, 57, 255),
  ["s"] = app.pixelColor.rgba(110, 190, 255, 255),
  ["x"] = app.pixelColor.rgba(190, 165, 140, 255),
  ["v"] = app.pixelColor.rgba(96, 90, 88, 255),
  ["*"] = app.pixelColor.rgba(255, 220, 80, 255),
  ["y"] = app.pixelColor.rgba(255, 200, 100, 255),
}

local function paint_rows(img, rows)
  for y = 1, #rows do
    local row = rows[y]
    for x = 1, #row do
      local ch = row:sub(x, x)
      local c = COL[ch]
      if not c then
        error("Unknown grid char: " .. tostring(ch))
      end
      img:drawPixel(x - 1, y - 1, c)
    end
  end
end

local function has_tag_named(spr, nm)
  for _, t in ipairs(spr.tags) do
    if t.name == nm then
      return true
    end
  end
  return false
end

local function add_named_tag(spr, nm, fromIdx, toIdx)
  if has_tag_named(spr, nm) then
    return
  end
  local a = spr.frames[fromIdx]
  local b = spr.frames[toIdx]
  local tag = spr:newTag(a, b)
  tag.name = nm
end

local src = root .. "bonnie-locomotion-v01.aseprite"
local spr = app.open(src)
if not spr then
  error("Could not open " .. src)
end
app.activeSprite = spr

local layer = spr.layers[1]
local BASE_FRAMES = 14
local TIER_FRAMES = #tier

-- P0: orphan frame 11 (0-based) = Lua frame 12 — tag jump_up
add_named_tag(spr, "jump_up", 12, 12)

if #spr.frames == BASE_FRAMES then
  -- P0: silhouette / rim on idle + walk tail separation (sparing #F4ECD8)
  local RIM = app.pixelColor.rgba(244, 236, 216, 255)
  local MID = app.pixelColor.rgba(61, 58, 56, 255)
  for i = 1, 4 do
    local cel = layer:cel(spr.frames[i])
    if cel then
      local img = cel.image
      img:drawPixel(7, 16, RIM)
      img:drawPixel(8, 20, RIM)
      img:drawPixel(5, 23, RIM)
    end
  end
  for i = 5, 11 do
    local cel = layer:cel(spr.frames[i])
    if cel then
      cel.image:drawPixel(2, 21, MID)
      cel.image:drawPixel(1, 22, MID)
    end
  end

  -- Tier A: append painted frames
  for _, entry in ipairs(tier) do
    spr:newFrame()
    local fr = spr.frames[#spr.frames]
    local img = Image(spr.spec)
    paint_rows(img, entry.rows)
    spr:newCel(layer, fr, img, Point(0, 0))
  end

  local n0 = BASE_FRAMES
  add_named_tag(spr, "sneak", n0 + 1, n0 + 2)
  add_named_tag(spr, "run", n0 + 3, n0 + 4)
  add_named_tag(spr, "double_jump", n0 + 5, n0 + 5)
  add_named_tag(spr, "land_skid", n0 + 6, n0 + 7)
  add_named_tag(spr, "slide", n0 + 8, n0 + 9)
  add_named_tag(spr, "climb", n0 + 10, n0 + 11)
  add_named_tag(spr, "ledge_cling", n0 + 12, n0 + 12)
  add_named_tag(spr, "ledge_pull", n0 + 13, n0 + 13)
  add_named_tag(spr, "wall_jump", n0 + 14, n0 + 14)
  add_named_tag(spr, "squeeze", n0 + 15, n0 + 16)
  add_named_tag(spr, "dazed", n0 + 17, n0 + 17)
  add_named_tag(spr, "rough_landing", n0 + 18, n0 + 19)
else
  print("bonnie_round1_v2: skip tier append (expected " ..
    BASE_FRAMES .. " base frames, have " .. #spr.frames .. ")")
end

-- Aseprite can extend the last tag when frames are appended — clamp jump_down to frame 14.
for _, t in ipairs(spr.tags) do
  if t.name == "jump_down" then
    t.fromFrame = spr.frames[14]
    t.toFrame = spr.frames[14]
  end
end

spr:saveAs(src)
print("bonnie_round1_v2: saved", src, "frames", #spr.frames, "tier_defs", TIER_FRAMES)
