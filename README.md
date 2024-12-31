# awesome-sile-books

Sources for several books and booklets, ready-to-compile with the SILE typesetting system.

## The books

These are books I have typeset with SILE, using my _re·sil·ient_ collection of classes & packages.
Most of them have a dedicated README file, with more details about the content and the process of typesetting, and a link to the published version.

I also use these works to check that _re·sil·ient_ is working as expected; and to test new features and to ensure the non-regression of these classes and packages when I update them.

### Published books

| File | Description |
| ---- | ----------- |
| **dragon-de-brume-5/dragon-de-brume-5.silm** | _On some stars, flowers & places in Middle-earth,_ published volume. [README](dragon-de-brume-5/README.md). |
| **dragon-de-brume-6/dragon-de-brume-6.silm** | _On cartography, maps & locations in Middle-earth,_ published volume. [README](dragon-de-brume-6/README.md). |
| **dragon-de-brume-hs/dragon-de-brume-hs.silm** | _A bibliography of Tolkien studies in French & English,_ published volume. [README](dragon-de-brume-hs/README.md). |

### Showcase booklets

| File | Description |
| ---- | ----------- |
| **lovecraft/lovecraft.silm**   | A selection of short stories by H. P. Lovecraft, in French. [READ](https://www.calameo.com/read/007349338e0ad825f365a). |
| **sile-maths/sile-maths.silm** | _SILE and the Hydra of Maths,_ a technical booklet. [README](sile-maths/README.md). |

### Advanced experiments

| File | Description |
| ---- | ----------- |
| **lsg/lsg.silm** | Bible Louis Segond 1910, in French. |
| **wulfila/wulfila.silm** | Wulfila's Gothic Bible, in Gothic and English. [README](wulfila/README.md). |


## Technical details

This section is for those who want to generate the PDFs themselves, or contribute to the sources.

### Check the pre-requisites

See further down for a Docker image, if you prefer to be quickly bootstrapped without installing anything on your host system.

Otherwise, you need to have the following tools installed.
You are on your own checking that you have the right versions of the dependencies and a proper working installation:

- [SILE](https://github.com/sile-typesetter/sile) 0.15.**8** or upper

  See installation instructions on the SILE website.

- [LuaRocks](https://luarocks.org/)

  See installation instructions on the LuaRocks website.

- The _re·sil·ient_ collection of classes & packages for SILE, a.k.a. [resilient.sile](https://github.com/Omikhleia/resilient.sile).

  ```bash
  luarocks install resilient.sile
  ```

  Be sure to upgrade to the latest version (_minimaly_ to **2.6** for best results).

- Decent choice of fonts: Libertinus, EB Garamond, Zallman Caps, Lato.

### Generate nice PDF of the books

For any book in the repository, you can generate a PDF with the following command, run from the base folder of this repository:

```bash
sile -u inputters.silm book/book.silm
```

Where `book/book.silm` is to be replaced by the path to the relevant document master file.

### Using a ready-to-go Docker image

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

## Contribute

You are of course welcome to report corrections or propose emendations and additions to the books.
The best preferred is to post an "issue" on the project repository here.

For more advanced readers who do know what it means: proposing a PR is even possible and appreciated, but be sure to fist discuss it in an issue before submitting anything.

Moreover, if you made books with the _re·sil·ient_ collection, and want to share them under the same umbrella, please get in touch with an issue.
We can certainly arrange to add them here, with proper credits and licensing.

## License

The books have varying licenses and some are used by courtesy of the authors.

Please check their respective license or ask, in case of doubts, for details and exact licensing terms.

By default, assume CC-BY-NC-SA 4.0 _at best._
The intent is that you can study the sources, and build them to produce your own PDF versions, but not use the latter without attribution and in commercial ways.

Extra clauses:

Distribution of these works or any derived works on websites such as Scribd is not allowed without our authorization.
We consider it would be a violation of the Non-Commercial clause, due to the nature of their business model.
Whether it stands legally or not, we explicitly forbid it.
