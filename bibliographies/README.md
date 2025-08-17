This folder contains bibliographies for some of our projects.

The bibliographies are organized by topic and are in BibTeX format, with some deviations by design:
 - All files are UTF-8 encoded.
 - There is no TeX-escaping of special characters, and no TeX-specific commands (i.e. no `{\relax ...}`, `\&`, etc.).
 - In article or book titles,
    - The `&` characters are always used unescaped,
    - The `~` character is used to indicate a non-breaking space (as in TeX, for convenience),
    - The `_text_` sequence is used to indicate italics (_à la_ Markdown),
    - The `$formula$` sequence is used to indicate math mode, in (a subset of) TeX-like syntax.
    - Double straight quotes are used for quoting, with the expectation that the renderer will convert them to curly quotes (possibly shifted to single quotes, if the citation style requires it).
    - In French works, spaces before "high punctuation" marks are not present, with the expectation that the renderer will add them as needed.

Currently, the bibliographies are focused on Tolkien-related essays, as part of the needs of Le Dragon de Brume, a French non-profit organization dedicated to the promotion of Tolkien studies.
