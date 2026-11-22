--- Script to re-generate a single BibTeX file compatible with JabRef
--
-- This module requires re·sil·ient v4.0 or later (with SILE v0.15.13 or later).
--
-- Usage:
--
-- `̀``bash
-- resilient gen-bibtex-jabref.lua
-- ```
--
-- Where `resilient` is a convenience alias (described in the README.md)
--
-- @license MIT
-- @copyright (c) 2026 Omikhleia / Didier Willis / Le Dragon de Brume

local CslExtendedProcessor = require("bibliographies.scripts.utils.csl-extended-processor").CslExtendedProcessor
local FU = require("bibliographies.scripts.utils.files")
local writeFile = FU.writeFile

local biblio = CslExtendedProcessor("dragon-de-brume-hs/dragon-de-brume-hs.silm")

local bibtexEntries = biblio:exportBibTeX()
-- Jabref biblatex compatible output
bibtexEntries[#bibtexEntries+1] = [[@Comment{jabref-meta: databaseType:biblatex;}]]
local out = table.concat(bibtexEntries, "\n") .. "\n"

writeFile("docs/bibliography/exported.bib", out)
os.exit(0)
