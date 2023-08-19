# awesome-sile-books

Sources for test books, ready-to-compile with SILE.

I use them to check that _re·sil·ient_ is working as expected; and to test new features and non-regression.

## Pre-requisites

- [SILE](https://github.com/sile-typesetter/sile) 0.14.**9** or upper

  See installation instructions on the SILE website.

- [LuaRocks](https://luarocks.org/)

  See installation instructions on the LuaRocks website.

- The _re·sil·ient_ collection of classes & packages for SILE, a.k.a. [resilient.sile](https://github.com/Omikhleia/resilient.sile).

  ```bash
  luarocks install resilient.sile
  ```

  Be sure to upgrade to the latest version (_minimaly_ to **2.1**).

- Decent choice of fonts: Libertinus, EB Garamond, Zallman Caps.

## PDF generation

For any book in the repository, you can generate a PDF with the following command:

```bash
sile -u inputters.silm book/book.silm
```

Where `book/book.silm` is the path to the relevant document master file:

- lovecraft: A selection of short stories by H. P. Lovecraft, in French.
- lsg: Bible Louis Segond, in French.

## License

The books have varying licenses and some are used by courtesy of the authors.

Please check their respective license or ask, in case of doubts, for details and exact licensing terms.

By default, assume CC-BY-NC-SA 4.0 _at best._
The intent is that you can study the sources, and build them to produce your PDF versions, but not use the latter without attribution and in commercial ways.

Extra clauses:

Distribution of derived works on websites such as Scribd is not allowed.
I consider it would be a violation of the Non-Commercial clause, due to the nature of they business model.
Whether it stands legally or not, I explicitly forbid it.
