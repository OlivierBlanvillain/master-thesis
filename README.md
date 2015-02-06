## To compile the report

You will need:

- Pandoc (install it [from source](http://johnmacfarlane.net/pandoc/installing.html#installing-from-source))
- [Adobe Caslon Pro](https://www.google.com/search?q=Adobe+Caslon+Pro+torrent)
- [Bitstream Vera Sans Mono](http://www.dafont.com/bitstream-vera-mono.font)
- Tex live (`apt-get install texlive-full` should do)

Then clone this repository with `git clone --recursive` to include the submodules, and call `latexmk` from the `report` directory. The presentation uses the [Linux Biolinum O](http://www.fontsquirrel.com/fonts/linux-biolinum) font and can be compiled the same way.

## How it works

`latexmk` takes care of all the compilation. `latexmkrc` defines how latex stuff should be compiles (xelatex, bibtex, incremental compilation triggered by file changes), and how to convert markdown files to latex and scala files to latex listings.

- **.md → .mdtex**: Uses Pandoc to compile markdown to latex. I additional the following semantic with a sed command:

    1. `@author` in markdown becomes `\cite{author}` in latex
    2. `#figure` in markdown becomes `\autoref{figure}` in latex
    3. `@@` in markdown becomes `@` in latex
    4. `##` in markdown becomes `#` in latex

- **.scala → .listings**: Uses a sed command to remove packages, imports, comments and empty lines from scala files. Thanks to this, every code included in the document can come from the project repo to avoid possible typos and ensure that the report is up to date with the project.

Finally, in order to make `content.md` as nice as possible, all the figures are defined as functions in `figures.tex`. Each function takes one argument, the figure caption, so that `content.md` contains all the text of the report.
