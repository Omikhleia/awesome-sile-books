--- Script to (re)-generate the list of journals in the bibliography.
--
-- It extracts all unique journal names from the bibliography,
-- along with their IDs (ISSN, e-ISSN, p-ISSN) if available.
-- It loads the existing journals from the JOURNAL_FILE to preserve any
-- manually added IDs, and updates the list with any new names or missing
-- IDs found in the bibliography.
-- Then it writes the updated list back to JOURNAL_FILE in YAML format.
--
-- This module requires re·sil·ient v4.0 or later (with SILE v0.15.13 or later).
--
--
-- Usage:
--
-- `̀``bash
-- resilient gen-journals-biblio.lua
-- ```
--
-- Where `resilient` is a convenience alias (described in the README.md)
--
-- @license MIT
-- @copyright (c) 2026 Omikhleia / Didier Willis / Le Dragon de Brume

-- https://portal.issn.org/api/search
-- https://portal.issn.org/resource/ISSN/xxxxx-xxxx
-- https://portal.issn.org/resource/ISSN-L/xxxxx-xxxx <---------- Consider linking ISSN-L too?
-- https://portal.issn.org/resource/ISSN/

local CslExtendedProcessor = require("bibliographies.scripts.utils.csl-extended-processor").CslExtendedProcessor
local writeFile = require("bibliographies.scripts.utils.files").writeFile

local biblio = CslExtendedProcessor("dragon-de-brume-hs/dragon-de-brume-hs.silm")

local JOURNAL_FILE = "bibliographies/tolkien/journals-biblio.yaml"
local ID_FIELDS = { "issn", "e-issn", "p-issn" }

local journals = biblio:getJournals(JOURNAL_FILE, ID_FIELDS)
writeFile(JOURNAL_FILE, journals)

os.exit(0)
