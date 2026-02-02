-- Copyright (c) 2026 Omikhleia / Didier Willis / Le Dragon de Brume
-- License: MIT

-- QUICK AND DIRTY SCRIPT TO GENERATE A LIST OF UNIQUE Journals FROM THE BIBLIOGRAPHY
-- https://portal.issn.org/api/search
-- https://portal.issn.org/resource/ISSN/xxxxx-xxxx
-- https://portal.issn.org/resource/ISSN-L/xxxxx-xxxx <---------- Consider linking ISSN-L too?
-- https://portal.issn.org/resource/ISSN/

-- Introduces a DUID (Dragon de Brume Unique Identifier) for each name
--    J0 + 10-digit hash of the name using zlib crc32
-- The 0 stands for v0 of the DUID format, and we'll see later if we need something more complex
-- in case of hash collisions, etc.

local bibparser = require("packages.bibtex.support.bibparser")
local crossrefAndXDataResolve = bibparser.crossrefAndXDataResolve
local yaml = require("resilient-tinyyaml")
local zlib = require("zlib")

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

local function loadBibliographyFromMaster (name)
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

local master = "dragon-de-brume-hs/dragon-de-brume-hs.silm"
local bibfiles = loadBibliographyFromMaster(master)

local CslProcessor = require("packages.bibtex.csl.processor")
local biblio = CslProcessor()
for _, file in ipairs(bibfiles) do
   biblio:loadBibliography(file)
end

local JOURNAL_FILE = "bibliographies/tolkien/journals-biblio.yaml"
local ID_FIELDS = { "issn", "e-issn", "p-issn" }

function CslProcessor:getJournals (options)
   print("Generating list of unique journal names from bibliography...")
   local orig = loadYamlFile(JOURNAL_FILE)
   local names = {}
   local listOfNames = {}
   for k, ent in pairs(orig) do
      names[ent.name] = {
         did = k,
      }
      for _, field in ipairs(ID_FIELDS) do
         if ent[field] then
            local name = pl.stringx.strip(ent.name)
            names[ent.name][field] = tostring(ent[field]) ~= "yaml.null" and ent[field] or nil
         end
      end
      table.insert(listOfNames, ent.name)
   end

   local bib

   bib = self._data.bib
   for key, entry in pairs(bib) do
      if entry.type ~= "xdata" then
         crossrefAndXDataResolve(bib, entry)
         if entry then
            local cslentry = self:_adapter(entry)
            -- handle only journal names for now
            if cslentry.type == "article-journal" or cslentry.type == "periodical" then   
               local field = cslentry["container-title-short"] or cslentry["container-title"]
               if field then
                  local fullname = field
                  if not names[fullname] then
                        table.insert(listOfNames, fullname)
                        names[fullname] = {}
                  end
               end
            end
         end
      end
   end
   -- Sort names alphabetically using locale-aware sorting (default is en-US)
   SU.collatedSort(listOfNames)
   print("Found " .. tostring(#listOfNames) .. " unique journals.")
   local yamlNames = {}
   local hashes = {}
   local nbWithIds = 0
   for _, fullname in ipairs(listOfNames) do
      local hasId = false
      local hash = string.format("%010d", zlib.crc32()(fullname))
      if hashes[hash] then
         SU.error("Hash collision for name: " .. fullname)
      end
      hashes[hash] = true
      table.insert(yamlNames, "J0" .. hash .. ":")
      table.insert(yamlNames, '  name: "' .. fullname:gsub('"', '\\"') .. '"')

      for _, field in ipairs(ID_FIELDS) do
         if names[fullname][field] then
            table.insert(yamlNames, '  ' .. field .. ': "' .. names[fullname][field] .. '"')
            hasId = true
         end
      end
      if hasId then
         nbWithIds = nbWithIds + 1
      end
   end
   print("  " .. tostring(nbWithIds) .. " with identifiers.")
   local yamlString = table.concat(yamlNames, "\n")
   return yamlString .. "\n"
end

local namesYaml = biblio:getJournals()
local outfile = io.open(JOURNAL_FILE, "w")
outfile:write(namesYaml)
outfile:close()
print("Wrote " .. JOURNAL_FILE)

os.exit(0)
