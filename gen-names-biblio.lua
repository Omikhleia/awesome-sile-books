-- Copyright (c) 2026 Omikhleia / Didier Willis / Le Dragon de Brume
-- License: MIT

-- QUICK AND DIRTY SCRIPT TO GENERATE A LIST OF UNIQUE NAMES FROM THE BIBLIOGRAPHY

-- Introduces a DUID (Dragon de Brume Unique Identifier) for each name
--    D0 + 10-digit hash of the name using zlib crc32
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

local AUTHOR_FILE = "bibliographies/tolkien/names-biblio.yaml"
local ID_FIELDS = { "orcid", "viaf", "isni", "wikidata", "idref", "hal" }

function CslProcessor:getNames (options)
   print("Generating list of unique author/editor/translator names from bibliography...")
   local orig = loadYamlFile(AUTHOR_FILE)
   local names = {}
   local listOfNames = {}
   for k, ent in pairs(orig) do
      names[ent.name] = {
         did = k,
      }
      for _, field in ipairs(ID_FIELDS) do
         if ent[field] then
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
            local cslentry = self:_adapter(entry, citnum)
            -- author, editor, translator
            for _, namefield in ipairs({ "author", "editor", "translator" }) do
               if cslentry[namefield] then
                  for _, name in ipairs(cslentry[namefield]) do
                     local fullname = name.given and (name.family .. ", " .. name.given) or name.family
                     if not names[fullname] then
                        table.insert(listOfNames, fullname)
                        names[fullname] = {}
                        -- Add IDs if present
                        for _, field in ipairs(ID_FIELDS) do
                           if name[field:upper()] then
                              names[fullname][field] = name[field:upper()]
                           end
                        end
                     else
                        -- Update IDs if missing from the existing entry
                        -- but present in the current bibliography entry
                        for _, field in ipairs(ID_FIELDS) do
                           if name[field:upper()] and not names[fullname][field] then
                              names[fullname][field] = name[field:upper()]
                           end
                        end
                     end
                     if name['dropping-particle'] and not names[fullname]['dropping-particle'] then
                        names[fullname]['dropping-particle'] = name['dropping-particle']  
                     end
                     if name['non-dropping-particle'] and not names[fullname]['non-dropping-particle'] then
                        names[fullname]['non-dropping-particle'] = name['non-dropping-particle']  
                     end
                     names[fullname]["roles"] = names[fullname]["roles"] or {}
                     names[fullname]["roles"][namefield] = pl.Set(
                        names[fullname]["roles"][namefield] or {}
                     ) + key
                  end
               end
            end
         end
      end
   end
   -- Sort names alphabetically using locale-aware sorting (default is en-US)
   SU.collatedSort(listOfNames)
   print("Found " .. tostring(#listOfNames) .. " unique names.")
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
      table.insert(yamlNames, "D0" .. hash .. ":")
      table.insert(yamlNames, "  name: " .. fullname)

      -- Simple roles list:
      local roles = names[fullname]["roles"] or {}
      local rolesList = {}
      for role, _ in pairs(roles) do
         table.insert(rolesList, role)
      end
      table.sort(rolesList)
      table.insert(yamlNames, '  roles: ["' .. table.concat(rolesList, '", "') .. '"]')

      -- OR full roles with entries:
      -- table.insert(yamlNames, "  roles:"
      -- for role, entries in pairs(names[fullname]["roles"] or {}) do
      --    table.insert(yamlNames, "    " .. role .. ":")
      --    print("Adding role " .. role .. " for " .. fullname, entries)
      --    for _, entry in ipairs(pl.Set.values(entries)) do
      --       table.insert(yamlNames, "      - " .. entry)
      --    end
      -- end
      for _, field in ipairs{"dropping-particle", "non-dropping-particle"} do
         if names[fullname][field] then
            table.insert(yamlNames, '  ' .. field .. ': "' .. names[fullname][field] .. '"')
         end
      end
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

local namesYaml = biblio:getNames()
local outfile = io.open(AUTHOR_FILE, "w")
outfile:write(namesYaml)
outfile:close()
print("Wrote " .. AUTHOR_FILE)

os.exit(0)
