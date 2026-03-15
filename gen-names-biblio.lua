--- Script to (re)-generate the list of names in the bibliography.
--
-- It extracts all unique author/editor/translator names from the bibliography,
-- along with their IDs (ORCID, VIAF, ISNI, Wikidata, IdRef, HAL) if available.
-- It loads the existing names from the AUTHOR_FILE to preserve any manually
-- added IDs, and updates the list with any new names or missing IDs found in
-- the bibliography.
-- Then it writes the updated list back to AUTHOR_FILE in YAML format.
--
-- This module requires re·sil·ient v4.0 or later (with SILE v0.15.13 or later).
--
-- Usage:
--
-- `̀``bash
-- resilient gen-names-biblio.lua
-- ```
--
-- Where `resilient` is a convenience alias (described in the README.md)
--
-- @license MIT
-- @copyright (c) 2026 Omikhleia / Didier Willis / Le Dragon de Brume

local CslExtendedProcessor = require("bibliographies.scripts.utils.csl-extended-processor").CslExtendedProcessor
local writeFile = require("bibliographies.scripts.utils.files").writeFile

local biblio = CslExtendedProcessor("dragon-de-brume-hs/dragon-de-brume-hs.silm")

local AUTHOR_FILE = "bibliographies/tolkien/names-biblio.yaml"
local ID_FIELDS = { "orcid", "viaf", "isni", "wikidata", "idref", "hal" }

local names = biblio:getNames(AUTHOR_FILE, ID_FIELDS)
writeFile(AUTHOR_FILE, names)

os.exit(0)
