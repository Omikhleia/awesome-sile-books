-- Copyright (c) 2025 Omikhleia / Didier Willis / Le Dragon de Brume
-- License: MIT

-- Quick and dirty script to generate HTML pages from the bibliographies
-- I'll want to do better later, but this is a (rough) start.

-- Usage:
--
-- `̀``bash
-- resilient gen-static-biblio.lua
-- ```
--
-- Where `resilient` is a convenience alias (described in the README.md)
--
-- NOTE: This assumes SILE 0.15.13 and a lot of fixes upstreamed to SILE (PR 2294).

local HTML_BEGIN_BIBLIO = ([[<!DOCTYPE html>
<html lang="%s">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>%s</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400..800;1,400..800&family=Lato:ital,wght@0,100;0,300;0,400;0,700;0,900;1,100;1,300;1,400;1,700;1,900&display=swap" rel="stylesheet">
<link href="../biblio.css" rel="stylesheet">
<script id="MathJax-script" async
  src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js">
</script>
<script>
  document.addEventListener("DOMContentLoaded", function () {
    // Select all links
    const links = document.querySelectorAll("a[href^='http']");
    links.forEach(link => {
      // Skip internal links (same origin)
      if (link.hostname !== window.location.hostname) {
        link.setAttribute("target", "_blank");
        link.setAttribute("rel", "noopener");
      }
    });
  });
</script>
</head>
<body>
<h1>%s</h1>
<h2>%s</h2>
<div class="bibliography">
]])

local HTML_BEGIN_INDEX = ([[<!DOCTYPE html>
<html lang="%s">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>%s</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400..800;1,400..800&family=Lato:ital,wght@0,100;0,300;0,400;0,700;0,900;1,100;1,300;1,400;1,700;1,900&display=swap" rel="stylesheet">
<link href="biblio.css" rel="stylesheet">
<script>
  document.addEventListener("DOMContentLoaded", function () {
    // Select all links
    const links = document.querySelectorAll("a[href^='http']");
    links.forEach(link => {
      // Skip internal links (same origin)
      if (link.hostname !== window.location.hostname) {
        link.setAttribute("target", "_blank");
        link.setAttribute("rel", "noopener");
      }
    });
  });
</script>
</head>
<body>
<h1>%s</h1>
<h2>%s</h2>
<div class="bibliography">
]])

local HTML_BEGIN_DJOT_RENDER = [[<!DOCTYPE html>
<html lang="%s">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>%s</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400..800;1,400..800&family=Lato:ital,wght@0,100;0,300;0,400;0,700;0,900;1,100;1,300;1,400;1,700;1,900&display=swap" rel="stylesheet">
<link href="djotted.css" rel="stylesheet">
<script id="MathJax-script" async
  src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js">
</script>
<script>
  document.addEventListener("DOMContentLoaded", function () {
    // Select all links
    const links = document.querySelectorAll("a[href^='http']");
    links.forEach(link => {
      // Skip internal links (same origin)
      if (link.hostname !== window.location.hostname) {
        link.setAttribute("target", "_blank");
        link.setAttribute("rel", "noopener");
      }
    });
  });
</script>
</head>
<body>
<div class="bibliography">
]]


local HTML_BEGIN_NAMES_RENDER = [[<!DOCTYPE html>
<html lang="%s">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>%s</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400..800;1,400..800&family=Lato:ital,wght@0,100;0,300;0,400;0,700;0,900;1,100;1,300;1,400;1,700;1,900&display=swap" rel="stylesheet">
<link href="biblio.css" rel="stylesheet">
<style>
.biblio-names-ids {
  font-size: 0.75em;
  border: 1px solid #666;
  border-radius: 4px;
  padding: 1px 2px;
  background-color: #f0f0f0;
}
.biblio-names-roles {
  width: 1em;
  aspect-ratio: 1 / 1;
  border: 1px solid;
  border-radius: 50%%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
  font-size: 0.75em;
  padding: 1px;
}
.role-author {
  border-color: #0f5132;
  background-color: #3e8a66;
  color: white;
}
.role-translator {
  border-color: #055160;
  background-color: #107788;
  color: white;
}
.role-editor {
   border-color: #5f0f3e;
   background-color: #9b375f;
   color: white;
}
</style>
<script>
  document.addEventListener("DOMContentLoaded", function () {
    // Select all links
    const links = document.querySelectorAll("a[href^='http']");
    links.forEach(link => {
      // Skip internal links (same origin)
      if (link.hostname !== window.location.hostname) {
        link.setAttribute("target", "_blank");
        link.setAttribute("rel", "noopener");
      }
    });
  });
</script>
</head>
<body>
<div class="bibliography">
]]

local HTML_END = [[</div>
</body>
</html>]]


local PAGES = {}
PAGES.en = {
   {
      ref = "books",
      title = "Tolkien Bibliography (Books)",
      h1 = "A bibliography of Tolkien studies",
      h2 = "Books &amp; Reviews",
      button = "Books &amp; Reviews",
      introduction = [[
<p>This view lists all books currently referenced in the bibliography, with reviews grouped as sub-entries, when available.
The citation style used is Chicago Author-Date, but modified as follows:
</p>
<ul>
<li>Subsequent authors are not replaced by em-dashes, but are listed with their full name.
&mdash; So you can copy a reference without having to supply any missing information.
</li>
<li>Books are sorted by date, then by author and title.
&mdash; So books are listed here with the <em>most recent</em> first, and then alphabetically by author and title.
</li>
<li>The ISBN is added to the end of the entry, when available.
&mdash; So it may help locating the book, but do not forget to remove it if you intend to use the reference in a paper,
and want to strictly adhere to the Chicago style.
</li>
</ul>
]],
      style = "omi-web-chicago-mod",
      language = "en-US",
      options = {
         cited = false,
         related = true,
         filter = "type-book",
      }
   },
   {
      ref = "mla",
      title = "Tolkien Bibliography (MLA)",
      h1 = "A bibliography of Tolkien studies",
      h2 = "All references in Modern Language Association style",
      button = "All references (MLA)",
      introduction = [[
<p>This view lists all references currently present in the bibliography.
The citation style used is MLA (Modern Language Association), but modified as follows:</p>
<ul>
<li>Subsequent authors are not replaced by em-dashes, but are listed with their full name.
&mdash; So you can copy a reference without having to supply any missing information.</li>
<li>The number of authors is not limited (whereas standard MLA style would use an “et al.” after the first author if there are more than three authors).
&mdash; So you can know all authors here, but do not forget to re-apply the MLA rules if you intend to use the reference in a paper strictly adhering to the MLA style.</li>
<li>Rules for demoting non-dropping name particles are slightly changed to the editor’s taste.</li>
<li>The collection title (for series, etc.) is included, when available.</li>
</ul>
]],
      style = "omi-web-mla-mod",
      language = "en-US",
      options = {
         cited = false,
      }
   },
   {
      ref = "chicago",
      title = "Tolkien Bibliography (Chicago)",
      h1 = "A bibliography of Tolkien studies",
      h2 = "All references in Chicago style",
      button = "All references (Chicago)",
      introduction = [[
<p>This view lists all references currently present in the bibliography.
The citation style used is Chicago Author-Date, but modified as follows:</p>
<ul>
<li>Subsequent authors are not replaced by em-dashes, but are listed with their full name.
&mdash; So you can copy a reference without having to supply any missing information.</li>
</ul>
]],
      style = "omi-chicago-author-date",
      language = "en-US",
      options = {
         cited = false,
      }
   },
}
PAGES.fr = {
   {
      ref = "books",
      title = "Bibliographie Tolkien (Livres)",
      h1 = "Une bibliographie des études tolkieniennes",
      h2 = "Livres &amp; Critiques",
      button = "Livres &amp; Critiques",
      introduction = [[
<p>Cette vue liste tous les livres actuellement référencés dans la bibliographie, avec les critiques regroupées en sous-entrées, le cas échéant.
La norme de citation utilisée est le Chicago Author-Date, mais modifiée comme suit :
</p>
<ul>
<li>Les auteurs répétés ne sont pas remplacés par des tirets, mais sont listés avec leur nom complet.
&mdash; Vous pouvez donc copier une référence sans avoir à fournir d’informations manquantes.</li>
<li>Les livres sont triés par date, puis par auteur et titre.
&mdash; Ainsi, les livres sont listés ici avec le <em>plus récent</em> en premier, puis par ordre alphabétique d’auteur et de titre.</li>
<li>L’ISBN est ajouté à la fin de l’entrée, lorsqu’il est disponible.
&mdash; Cela peut aider à localiser le livre, mais n’oubliez pas de le supprimer si vous souhaitez utiliser la référence dans un article,
et que vous voulez adhérer strictement au style Chicago.</li>
</ul>
]],
      style = "omi-web-chicago-fr-mod",
      language = "fr-FR",
      options = {
         cited = false,
         related = true,
         filter = "type-book",
      }
   },
   {
      ref = "chicago",
      title = "Bibliographie Tolkien (Chicago)",
      h1 = "Une bibliographie des études tolkieniennes",
      h2 = "Toutes les références en style Chicago",
      button = "Toutes les références (Chicago)",
      introduction = [[
<p>Cette vue liste toutes les références actuellement présentes dans la bibliographie.
La norme de citation utilisée est le Chicago Author-Date, mais modifiée comme suit :</p>
<ul>
<li>Les auteurs répétés ne sont pas remplacés par des tirets, mais sont listés avec leur nom complet.
&mdash; Vous pouvez donc copier une référence sans avoir à fournir d’informations manquantes.</li>
</ul>
]],
      style = "omi-chicago-author-date-fr",
      language = "fr-FR",
      options = {
         cited = false,
      }
   },
   {
      ref = "iso690",
      title = "Bibliographie Tolkien (ISO 690)",
      h1 = "Une bibliographie des études tolkieniennes",
      h2 = "Toutes les références en style ISO 690",
      button = "Toutes les références (ISO 690)",
      introduction = [[
<p>Cette vue liste toutes les références actuellement présentes dans la bibliographie.
La norme de citation utilisée est l’ISO 690, mais modifiée comme suit :</p>
<ul>
<li>Les auteurs répétés ne sont pas remplacés par des tirets, mais sont listés avec leur nom complet.
&mdash; Vous pouvez donc copier une référence sans avoir à fournir d’informations manquantes.</li>
<li>En cas d’absence de lieu de publication, la mention “[S. l.]” est omise.
&mdash; Elle n’est pas réellement nécessaire de nos jours…</li>
</ul>
]],
      style = "omi-web-iso690-fr-mod",
      language = "fr-FR",
      options = {
         cited = false,
      },
   }
}

local function doNiceNavigationButtons (pages, selected)
   local html = '<div class="buttons">\n'
   -- Hamburger symbol = &#9776; (U+2630)
   if not selected then
      html = html .. '<span class="selected">&#9776;</span>\n'
   else
      html = html .. '<a href="../index.html">&#9776;</a>\n'
   end
   for _, page in ipairs(pages) do
      if page.ref == selected then
         html = html .. string.format(
            '<span class="selected">%s</span>\n',
            page.button
         )
      else
         html = html .. string.format(
            '<a href="%s.html">%s</a>\n',
            page.ref, page.button
         )
      end
   end
   html = html .. '</div>\n'
   return html
end

local function doIndexButton ()
   return [[<div class="buttons">
<a href="index.html">&#9776;</a>
</div>]]
end

local COPYRIGHT = ([[
<div class="copyright">
  <p>© <a href="https://sites.google.com/site/dragonbrumeux/bibliography">Le Dragon de Brume</a></p>
  <p><small>%s</small></p>
  <p><a href="https://creativecommons.org/licenses/by-sa/4.0/">CC BY-SA 4.0</a></p>
  <p><img src="https://mirrors.creativecommons.org/presskit/icons/cc.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/by.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/sa.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"></p>
</div>
]]):format(os.date("%Y-%m-%d %H:%M:%S"))

function writeHtml (outputFile, biblio, out, page, pages)
   out = HTML_BEGIN_BIBLIO:format(biblio:getCslEngine().locale.lang, page.title, page.h1, page.h2)
       .. COPYRIGHT
       .. doNiceNavigationButtons(pages, page.ref)
       .. "<div class=\"introduction\">\n"
       .. page.introduction
       .. "</div>\n"
       .. biblio:_toHtml(out, false)
       .. "<hr>\n"
       .. HTML_END
   local file = io.open(outputFile, "w")
   if not file then
      SU.error("Could not open output file: " .. outputFile)
   end

   file:write(out)
   file:close()
end

-- Emojis for flags:
-- English flag U+1F1EC U+1F1E7
-- French flag U+1F1EB U+1F1F7
local INDEXES = {
   { ref = "en/books", button = "English &#x1F1EC;&#x1F1E7;" },
   { ref = "fr/books", button = "Français &#x1F1EB;&#x1F1F7;" },
}

local TEXTS = {
   { ref = "intro", button = "Foreword" },
   { ref = "names", button = "Index of Names" },
   { ref = "outro", button = "Afterword" },
}

local GITHUB_LOGO = [[<svg height="32" aria-hidden="true" viewBox="0 0 24 24" version="1.1" width="32" data-view-component="true" class="octicon octicon-mark-github v-align-middle">
  <path d="M12 1C5.923 1 1 5.923 1 12c0 4.867 3.149 8.979 7.521 10.436.55.096.756-.233.756-.522 0-.262-.013-1.128-.013-2.049-2.764.509-3.479-.674-3.699-1.292-.124-.317-.66-1.293-1.127-1.554-.385-.207-.936-.715-.014-.729.866-.014 1.485.797 1.691 1.128.99 1.663 2.571 1.196 3.204.907.096-.715.385-1.196.701-1.471-2.448-.275-5.005-1.224-5.005-5.432 0-1.196.426-2.186 1.128-2.956-.111-.275-.496-1.402.11-2.915 0 0 .921-.288 3.024 1.128a10.193 10.193 0 0 1 2.75-.371c.936 0 1.871.123 2.75.371 2.104-1.43 3.025-1.128 3.025-1.128.605 1.513.221 2.64.111 2.915.701.77 1.127 1.747 1.127 2.956 0 4.222-2.571 5.157-5.019 5.432.399.344.743 1.004.743 2.035 0 1.471-.014 2.654-.014 3.025 0 .289.206.632.756.522C19.851 20.979 23 16.854 23 12c0-6.077-4.922-11-11-11Z"></path>
</svg>]]

local GITHUB_LINK = [[<a href="https://github.com/Omikhleia/awesome-sile-books/tree/main/bibliographies">%s</a>]]

local function writeIndexHtml ()
   local indexFile = "docs/bibliography/index.html"
   local indexOut = HTML_BEGIN_INDEX:format(
      "en-US",
      "Tolkien Bibliography",
      "A bibliography of Tolkien studies in French and English",
      "Une bibliographie des études tolkieniennes en français et en anglais"
   )

   indexOut = indexOut .. COPYRIGHT
      .. doNiceNavigationButtons(INDEXES)
      .. '<div class="center"><img class="image" src="books-shelf-public-domain.jpg" alt="Books on a shelf"></div>\n'
      .. doNiceNavigationButtons(TEXTS)
      .. '<div class="contribute">\n'
      .. GITHUB_LINK:format(GITHUB_LOGO)
      .. ("<span>&nbsp;Contribute to the %s / Contribuer à la %s.</span>\n")
         :format(GITHUB_LINK:format("bibliography"), GITHUB_LINK:format("bibliographie"))
      .. '</div>\n'
      .. "<hr>\n"
      .. HTML_END
   local file = io.open(indexFile, "w")
   if not file then
      SU.error("Could not open index file: " .. indexFile)
   end
   file:write(indexOut)
   file:close()
   print("Generated index page: " .. indexFile)
end

writeIndexHtml()

local function loadBibliographyFromMaster (name)
   local yaml = require("resilient-tinyyaml")
   local fname = SILE.resolveFile(name)
   local file = io.open(fname, "r")
   if not file then
      SU.error("Could not open master bibliography file: " .. name)
   end
   local content = file:read("*all")
   file:close()
   local master = yaml.parse(content)
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

for lang, pages in pairs(PAGES) do
   for _, page in ipairs(pages) do
      biblio:setBibliographyStyle(page.style, page.language)
      local engine = biblio:getCslEngine()
      engine.subsequentAuthorSubstitute = nil

      local out = biblio:bibliography(page.options)
      local outputFile = ("docs/bibliography/%s/%s.html"):format(lang, page.ref)
      writeHtml(outputFile, biblio, out, page, pages)
      print("Generated bibliography page: " .. outputFile)
   end
end

local djot = require("djot")

local function djotToHtml(filename, title)
   if pl.path.extension(filename) ~= ".dj" then
      error("File must have a .dj extension: " .. filename)
   end
   local file = io.open(filename, "r")
   if not file then
      error("Could not open file: " .. filename)
   end

   local input = file:read("*all")
   file:close()

   local doc = djot.parse(input)
   local html = djot.render_html(doc)

   html = HTML_BEGIN_DJOT_RENDER:format(
      "en-US",
      "Tolkien Bibliography - " .. title
   )
   .. COPYRIGHT
   .. doIndexButton()
   .. html
   .. HTML_END

   local outputFile = ("docs/bibliography/%s"):format(pl.path.basename(filename):gsub("%.dj$", ".html"))
   local outFile = io.open(outputFile, "w")
   if not outFile then
      error("Could not open output file: " .. outputFile)
   end
   outFile:write(html)
   outFile:close()
   print("Generated HTML from " .. filename .. " to " .. outputFile)
end

djotToHtml("dragon-de-brume-hs/en/intro.dj", "Foreword")
djotToHtml("dragon-de-brume-hs/en/outro.dj", "Afterword")

-- Names file is generated with gen-names-biblio.lua, here we just convert it to HTML
local function loadYamlFile (name)
   local yaml = require("resilient-tinyyaml")
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

local IDS_PREFIXES = {
   viaf = "https://viaf.org/viaf/",
   isni = "https://isni.org/isni/",
   wikidata = "https://www.wikidata.org/wiki/",
   orcid = "https://orcid.org/",
   idref = "https://www.idref.fr/",
   hal = "https://cv.hal.science/",
}

local function doRoles(ent)
   if not ent.roles then
      return ""
   end
   local out = {}
   local roles = ent.roles
   for _, role in ipairs(ent.roles) do
      table.insert(out, string.format(
         '<span class="biblio-names-roles role-%s">%s</span>',
         role,
         role:sub(1,1):upper()
      ))
   end
   if #out == 0 then
      return ""
   end
   return table.concat(out, " ")
end

local function doIdLinks(ent)
   local out = {}
   for _, idtype in ipairs({"viaf", "isni", "wikidata", "orcid", "idref", "hal"}) do
      local prefix = IDS_PREFIXES[idtype]
      local links = {}
      if ent[idtype] then
         -- Some IDs may have multiple values separated by spaces
         for _, id in ipairs(pl.stringx.split(ent[idtype], " ")) do
            table.insert(links, string.format('<a class="" href="%s%s">%s</a>', prefix, id, id))
         end
         table.insert(out, string.format('<span class="biblio-names-ids">%s %s</span>',
            idtype:upper(),
            table.concat(links, ", ")
         ))
      end
   end
   if #out == 0 then
      return ""
   end
   return " — " .. table.concat(out, " ")
end

local function namesBiblioToHtml(filename)
   local names = loadYamlFile(filename)
   -- Structure is:
   -- DragonUniqueID:
   --    name: Full Name
   --    viaf: xxxx
   --    isni: xxxx
   --    wikidata: xxxx
   --    orcid: xxxx
   --    idref: xxxx
   --    hal: xxxx
   local t = {}
   local indexOfNames = {}
   for k, ent in pairs(names) do
      t[ent.name] = ent
      table.insert(indexOfNames, ent.name)
   end
   SU.collatedSort(indexOfNames)

   print("Generating names bibliography page...")
   local th = {}
   -- Just lists, not HTML escaping
   for _, name in ipairs(indexOfNames) do
      local ent = t[name]
      local line = "<div class=\"biblio-entry\">\n"
      local name = ent.name
      if ent["dropping-particle"] then
         name = name .. " " .. ent["dropping-particle"]
      end
      if ent["non-dropping-particle"] then
         name = ent["non-dropping-particle"] .. " " .. name
      end
      line = line .. string.format("%s\n", name)
      line = line .. doRoles(ent)
      line = line .. doIdLinks(ent) .. "\n"
      line = line .. "</div>\n"
      table.insert(th, line)
   end

   local out = HTML_BEGIN_NAMES_RENDER:format(
      "en-US",
      "Tolkien Bibliography - Names",
      "A bibliography of Tolkien studies",
      "Names Index"
   )
   out = out .. COPYRIGHT
      .. doIndexButton()
      .. "<h1>Index of Names</h1>\n"
       .. "<div class=\"introduction\">\n"
       .. [[
<p>This page lists the names of persons referenced in the bibliography, along with their identifiers in various authority files, when available.</p>
<p>You can help us here, by contributing missing identifiers for persons already listed, and checking the correctness of existing ones.</p>
<p>But be careful to reference the correct person, as many names may be shared by several distinct persons!</p>
]]
       .. "</div>\n"
      .. table.concat(th, "\n")
      .. "<hr>\n"
      .. HTML_END
   local outputFile = "docs/bibliography/names.html"
   local file = io.open(outputFile, "w")
   if not file then
      SU.error("Could not open output file: " .. outputFile)
   end
   file:write(out)
   file:close()
   print("Generated names bibliography page: " .. outputFile)
end

namesBiblioToHtml("bibliographies/tolkien/names-biblio.yaml")

os.exit(0)
