--- File utility functions for bibliography scripts.
--
-- @license MIT
-- @copyright (c) 2025-2026 Omikhleia / Didier Willis / Le Dragon de Brume

local yaml = require("resilient-tinyyaml")

--- Loads a YAML file and returns its content as a Lua table.
--
-- @tparam string name Name of the YAML file to load
-- @treturn table Content of the YAML file as a Lua table
local function loadYamlFile (name)
  local fname = SILE.resolveFile(name)
  local file = io.open(fname, "r")
  if not file then
    SU.error("Could not open YAML file: " .. name)
  end
  local content = file:read("*all")
  file:close()
  local data = yaml.parse(content)
  if not data then
    SU.error("Could not parse YAML file: " .. name)
  end
  return data
end

--- Writes data to a file.
--
-- @tparam string name Name of the file to write to
-- @tparam string data Data to write to the file
local function writeFile (name, data)
  local outfile = io.open(name, "w")
  outfile:write(data)
  outfile:close()
  print("Wrote " .. name)
end

--- Loads the bibliography files listed in the master bibliography file.
--
-- The master document here is supposed to be a re·sil·ient master file in YAML format.
-- In other words, it's the same file as used to produce the PDF version of the bibliography.
-- This function extracts the list of bibliography files from the master document,
-- and returns it as a table.
--
-- @tparam string name Name of the re·sil·ient master document
-- @treturn table List of bibliography files extracted from the master document
local function loadBibliographyFromMasterDocument (name)
  local master = loadYamlFile(name)
  if not master then
    SU.error("Could not parse master bibliography file: " .. name)
  end
  local bibfiles = master.bibliography and master.bibliography.files
  if not bibfiles then
    SU.error("No bibliography files found in master file: " .. name)
  end
  return bibfiles
end

return {
  loadYamlFile = loadYamlFile,
  loadBibliographyFromMasterDocument = loadBibliographyFromMasterDocument,
  writeFile = writeFile,
}
