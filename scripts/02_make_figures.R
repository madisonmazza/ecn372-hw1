#!/usr/bin/env Rscript

# ------------------------------------------------------------------------------
# ECN 372 Homework 1 — Figure Replication
#
# This script regenerates:
#   - output/figure-1-bubble-trends.pdf
#   - output/figure-2-ribbon-median-weighted.pdf
# from the gapminder dataset.
#
# Reproducibility notes:
# - Tested with R 4.4.1.
# - Uses CRAN packages: gapminder, dplyr, ggplot2, tidyr.
# - Run from project root: Rscript scripts/02_make_figures.R
# - Working directory is set to project root when run via Rscript.
# - Quantiles use type = 7 (R default) for reproducibility.
# ------------------------------------------------------------------------------

set.seed(42)

# Set working directory to project root when run via Rscript
args <- commandArgs(trailingOnly = FALSE)
file_arg <- args[grepl("^--file=", args)]
if (length(file_arg) > 0L) {
  script_dir <- dirname(sub("^--file=", "", file_arg))
  setwd(file.path(script_dir, ".."))
}

required_packages <- c("gapminder", "dplyr", "ggplot2", "tidyr")

install_if_missing <- function(pkgs) {
  installed <- rownames(installed.packages())
  to_install <- setdiff(pkgs, installed)
  if (length(to_install) > 0) {
    install.packages(to_install, repos = "https://cloud.r-project.org")
  }
}

install_if_missing(required_packages)

suppressPackageStartupMessages({
  library(gapminder)
  library(dplyr)
  library(ggplot2)
  library(tidyr)
})

# Ensure output directory exists ----------------------------------------------

if (!dir.exists("output")) {
  dir.create("output", recursive = TRUE)
}

data("gapminder", package = "gapminder")

# =============================================================================
# FIGURE 1: Bubble scatter (GDP per capita vs life expectancy, 2007)
# =============================================================================

gap_2007 <- gapminder %>%
  filter(year == 2007)

p1 <- ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point(aes(size = pop, color = continent), alpha = 0.6) +
  scale_x_log10() +
  geom_smooth(aes(group = continent), method = "loess", se = FALSE) +
  geom_smooth(aes(group = 1), method = "loess", se = FALSE, color = "black", linewidth = 1) +
  scale_size(range = c(1, 20), guide = "none") +
  labs(
    title = "GDP per Capita vs Life Expectancy (2007)",
    x = "GDP per Capita (log scale)",
    y = "Life Expectancy"
  ) +
  theme_minimal(base_size = 12)

ggsave("output/figure-1-bubble-trends.pdf", p1, width = 8, height = 6)

# =============================================================================
# FIGURE 2: Ribbon (IQR) + median + population-weighted mean by continent
# =============================================================================

summary_df <- gapminder %>%
  group_by(continent, year) %>%
  summarize(
    q25 = quantile(lifeExp, 0.25, type = 7),
    q75 = quantile(lifeExp, 0.75, type = 7),
    median_life = median(lifeExp),
    weighted_mean = weighted.mean(lifeExp, pop),
    .groups = "drop"
  )

# Long form for legend: Median vs Population-weighted mean
summary_df_long <- summary_df %>%
  pivot_longer(
    cols = c(median_life, weighted_mean),
    names_to = "measure",
    values_to = "value"
  ) %>%
  mutate(measure = if_else(measure == "median_life", "Median", "Population-weighted mean"))

p2 <- ggplot(summary_df, aes(x = year)) +
  geom_ribbon(aes(ymin = q25, ymax = q75, fill = continent), alpha = 0.3) +
  geom_line(
    data = summary_df_long,
    aes(y = value, color = continent, linetype = measure),
    linewidth = 1
  ) +
  scale_linetype_manual(
    values = c("Median" = "solid", "Population-weighted mean" = "dashed"),
    name = NULL
  ) +
  facet_wrap(~ continent) +
  labs(
    title = "Life expectancy over time (within each continent)",
    x = "Year",
    y = "Life expectancy (years)",
    caption = "Ribbon = country-level IQR (25th–75th percentile) each year. Data: gapminder package."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    legend.key.width = grid::unit(1.2, "cm")
  )

ggsave("output/figure-2-ribbon-median-weighted.pdf", p2, width = 10, height = 7)
