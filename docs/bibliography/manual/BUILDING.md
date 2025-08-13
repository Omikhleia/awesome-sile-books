# (Re-)Building the bibliography

These procedures describe how to build an HTML or PDF version of the bibliography from the core source BibTeX-like files.

## Principles

The core source bibliography files are in "simplified" Bib(La)TeX-like format, but with some deviations by design.

 - All files are UTF-8 encoded.
 - There is no TeX-escaping of special characters, and no TeX-specific commands (i.e. no `{\relax ...}`, `\&`, etc.).
 - In article or book titles,
    - The `&` characters are always used unescaped,
    - The `~` character is used to indicate a non-breaking space (as in TeX, for convenience),
    - The `_text_` sequence is used to indicate italics (_à la_ Markdown),
    - The `$formula$` sequence is used to indicate math mode, in (a subset of) TeX-like syntax.
    - Double straight quotes are used for quoting, with the expectation that the renderer will convert them to curly quotes (possibly shifted to single quotes, if the citation style requires it).
    - In French works, spaces before "high punctuation" marks are not present, with the expectation that the renderer will add them as needed.

## Prerequisites

You will need a working installation of the SILE typesetter, the _re·sil·ient_ collection of modules, and some other tools.

User-friendly instructions may be provided in the future, but for now, refer to the main README at the root of the repository.

## Conversions

### Conversion to HTML (static web site)

To generate an HTML version of the bibliography (in the `docs/bibliography/` folder), clone the repository and run the following command from the base folder of the repository:

```shell
resilient gen-static-biblio.lua 
```

Open the generated `docs/bibliography/index.html` file in your web browser and start browsing the bibliography.

### Generation of the PDF booklet

To generate the PDF booklet, clone the repository and run the following command from the base folder of the repository:

```shell
resilient dragon-de-brume-hs/dragon-de-brume-hs.silm
```

This will generate the PDF booklet as `dragon-de-brume-hs/dragon-de-brume-hs.pdf`.

## Extending the bibliography

The HTML and PDF versions of the bibliography are generated using a set of BibTeX-like files, which are located in the `bibliographies/` folder.

They both use the same list of files, which is defined in a dedicated section of the `dragon-de-brume-hs/dragon-de-brume-hs.silm` file (the "master document" for the PDF booklet).

Would you like to add a new bibliography files? Here is how to do it:
 - Add the new BibTeX-like file to the `bibliographies/` folder at the appropriate place, 
   following the above-mentioned syntax and conventions.
 - Update the `dragon-de-brume-hs/dragon-de-brume-hs.silm` file to include the new file in the list of bibliography files.

## Bibliography styles

Both the HTML and PDF versions of the bibliography use citation styles in CSL format (Citation Style Language), slightly modified to fit the needs of the project.

All the CSL files are located in the `csl/` folder of the repository.

Note that SILE's CSL module is still in development, so some features may not be supported yet, or may not work as expected.
Would you like to have a specific citation style supported? You can help by reporting issues or, if you are a developer, by
contributing to the development of the SILE CSL module.
