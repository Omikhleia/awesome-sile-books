# awesome-sile-books

Sources for test books, ready-to-compile with SILE.

I use them to check that _re·sil·ient_ is working as expected; and to test new features and non-regression.

## Check the pre-requisites

You are on your own checking that you have the right versions of the dependencies and a proper working installation:

- [SILE](https://github.com/sile-typesetter/sile) 0.14.**9** or upper

  See installation instructions on the SILE website.

- [LuaRocks](https://luarocks.org/)

  See installation instructions on the LuaRocks website.

- The _re·sil·ient_ collection of classes & packages for SILE, a.k.a. [resilient.sile](https://github.com/Omikhleia/resilient.sile).

  ```bash
  luarocks install resilient.sile
  ```

  Be sure to upgrade to the latest version (_minimaly_ to **2.2** for best results).

- Decent choice of fonts: Libertinus, EB Garamond, Zallman Caps, Lato.

Or see further down for a Docker image, if you prefer to be quickly bootstrapped without installing anything.

## Generate nice PDF of the books

For any book in the repository, you can generate a PDF with the following command, run from the base folder of this repository:

```bash
sile -u inputters.silm book/book.silm
```

Where `book/book.silm` is to be replaced by the path to the relevant document master file:

- **lovecraft/lovecraft.silm**: A selection of short stories by H. P. Lovecraft, in French.
- **lsg/lsg.silm**: Bible Louis Segond 1910, in French.
- **dragon-de-brume-5/dragon-de-brume-5.silm**: _On some stars, flowers & places in Middle-earth,_ published volume. See dedicated [README](dragon-de-brume-5/README.md).

## Or with a ready-to-go Docker image

If you have Docker installed, you can use the provided Docker file to build an image containing SILE, Luarocks, the _re·sil·ient_ collection, other tools used by some of the modules, and a curated set of good fonts.

Everything is then ready for you to get quickly bootstrapped.

From the base folder of this repository, build an image:

```bash
docker build --progress plain . -f build/Dockerfile -t silex
```

Then create an alias, say `resilient`, to run the image:

```bash
alias resilient='docker run -it --volume "$(pwd):/data" --user "$(id -u):$(id -g)" silex'
```

And use it instead of `sile`:

```bash
resilient -u inputters.silm book/book.silm
```

Be sure to rebuild the image from time to time, so that it is updated with the latest versions of the tools.
This is assuming you know the basics of Docker, of course.

## Show your appreciation

If you like this repository, please also star ⭐ [resilient.sile](https://github.com/Omikhleia/resilient.sile), [markdown.sile](https://github.com/Omikhleia/markdown.sile) and obviously [SILE](https://github.com/sile-typesetter/sile) too.

## License

The books have varying licenses and some are used by courtesy of the authors.

Please check their respective license or ask, in case of doubts, for details and exact licensing terms.

By default, assume CC-BY-NC-SA 4.0 _at best._
The intent is that you can study the sources, and build them to produce your own PDF versions, but not use the latter without attribution and in commercial ways.

Extra clauses:

Distribution of these works or any derived works on websites such as Scribd is not allowed without our authorization.
We consider it would be a violation of the Non-Commercial clause, due to the nature of their business model.
Whether it stands legally or not, we explicitly forbid it.
