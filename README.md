# ECN 372 Homework 1

This repository replicates two figures using the `gapminder` dataset.

### Repo Structure

- **`scripts/`**  
  - **`02_make_figures.R`**: Generates both figures from the `gapminder` dataset using `dplyr` and `ggplot2`.

- **`output/`**  
  Destination folder for the generated figures. After running the script, it will contain:
  - **`figure-1-bubble-trends.pdf`** – bubble/scatter plot of GDP per capita vs. life expectancy (2007), with point size representing population and LOESS trend lines (overall and by continent).
  - **`figure-2-ribbon-median-weighted.pdf`** – ribbon and line plot of life expectancy over time by continent, showing interquartile ranges, medians, and population‑weighted means.

- **`README.md`**  
  This documentation file, describing structure, replication steps, and the reverse‑engineering process.

- **`AI_USAGE.md`**  
  Notes on how AI tools were used in this assignment.

### Replication Instructions

From the project root, run the following in a terminal or shell:

```bash
Rscript scripts/02_make_figures.R
```

### Reverse-Engineering Process

I started by feeding the figure descriptions from the assignment into the Cursor AI agent and asking it to generate an initial version of each figure. Cursor Agent generated both PDFs from the Gapminder data (including a small install_if_missing() helper and a weighted_median() function for the ribbon plot). After that, I compared the generated plots to the target figures in detail, checking things like the axis scales and labels, the use of color, the layout of the plots, and where legends and lines appeared. I tested the code by running the script and comparing the output to the original figures, making small adjustments until the replicated figures matched the main features of the originals.

### AI Usage

See the `AI_USAGE.md` to see log of AI use