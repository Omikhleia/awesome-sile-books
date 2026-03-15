--- Bibliography processing methods.
--
-- This module requires re·sil·ient v4.0 or later (with SILE v0.15.13 or later).
--
-- @license MIT
-- @copyright (c) 2025-2026 Omikhleia / Didier Willis / Le Dragon de Brume

local yaml = require("resilient-tinyyaml")
local zlib = require("zlib")

local bibparser = require("packages.dissilient.bibtex.support.bibparser")
local crossrefAndXDataResolve = bibparser.crossrefAndXDataResolve
local CslProcessor = require("packages.dissilient.bibtex.csl.processor")

local FU = require("bibliographies.scripts.utils.files")
local loadBibliographyFromMasterDocument = FU.loadBibliographyFromMasterDocument
local loadYamlFile = FU.loadYamlFile

function CslProcessor:getNames (AUTHOR_FILE, ID_FIELDS)
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

function CslProcessor:getJournals (JOURNAL_FILE, ID_FIELDS)
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

local CslExtendedProcessor = function (master)
  local biblio = CslProcessor()
  local bibfiles = loadBibliographyFromMasterDocument(master)
  for _, file in ipairs(bibfiles) do
    biblio:loadBibliography(file)
  end
  return biblio
end

return {
  CslExtendedProcessor = CslExtendedProcessor,
}
