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
# - Uses CRAN packages: gapminder, dplyr, ggplot2.
# - The script will try to install any missing packages from CRAN.
# ------------------------------------------------------------------------------

required_packages <- c("gapminder", "dplyr", "ggplot2")

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
})

# Ensure output directory exists ----------------------------------------------

if (!dir.exists("output")) {
  dir.create("output", recursive = TRUE)
}

# Helper: weighted median -----------------------------------------------------

weighted_median <- function(x, w) {
  stopifnot(length(x) == length(w))
  if (length(x) == 0L) return(NA_real_)
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  w <- w / sum(w)
  cum_w <- cumsum(w)
  x[which(cum_w >= 0.5)[1]]
}

data("gapminder", package = "gapminder")

# Figure 1: Bubble trends -----------------------------------------------------

fig1 <- ggplot(
  gapminder,
  aes(
    x = year,
    y = lifeExp,
    size = pop / 1e6,
    colour = continent,
    group = country
  )
) +
  geom_line(alpha = 0.4) +
  geom_point(alpha = 0.6) +
  scale_size_continuous(
    name = "Population (millions)",
    range = c(0.5, 8),
    guide = "legend"
  ) +
  labs(
    title = "Life expectancy over time (Gapminder)",
    x = "Year",
    y = "Life expectancy at birth"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "right"
  )

ggsave(
  filename = "output/figure-1-bubble-trends.pdf",
  plot = fig1,
  width = 8.5,
  height = 5.5
)

# Figure 2: Ribbon of weighted median life expectancy -------------------------

gapminder_median <- gapminder %>%
  group_by(continent, year) %>%
  summarise(
    weighted_median_lifeExp = weighted_median(lifeExp, pop),
    .groups = "drop"
  )

fig2 <- ggplot(
  gapminder_median,
  aes(
    x = year,
    y = weighted_median_lifeExp,
    fill = continent
  )
) +
  geom_ribbon(
    aes(
      ymin = 0,
      ymax = weighted_median_lifeExp
    ),
    alpha = 0.5
  ) +
  labs(
    title = "Weighted median life expectancy by continent (Gapminder)",
    x = "Year",
    y = "Weighted median life expectancy"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "right"
  )

ggsave(
  filename = "output/figure-2-ribbon-median-weighted.pdf",
  plot = fig2,
  width = 8.5,
  height = 5.5
)

library(tidyverse)
library(gapminder)

# Make sure output folder exists
dir.create("output", showWarnings = FALSE)

# =========================
# FIGURE 1: Bubble scatter
# =========================

gap_2007 <- gapminder %>%
  filter(year == 2007)

p1 <- ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point(aes(size = pop, color = continent), alpha = 0.6) +
  scale_x_log10() +
  geom_smooth(aes(group = 1), method = "loess", se = FALSE, color = "black") +
  geom_smooth(aes(group = continent), method = "loess", se = FALSE) +
  scale_size(range = c(1, 20), guide = "none") +
  labs(
    title = "GDP per Capita vs Life Expectancy (2007)",
    x = "GDP per Capita (log scale)",
    y = "Life Expectancy"
  ) +
  theme_minimal()

ggsave("output/figure-1-bubble-trends.pdf", p1, width = 8, height = 6)


# ===============================
# FIGURE 2: Ribbon + lines
# ===============================

summary_df <- gapminder %>%
  group_by(continent, year) %>%
  summarize(
    q25 = quantile(lifeExp, 0.25),
    q75 = quantile(lifeExp, 0.75),
    median_life = median(lifeExp),
    weighted_mean = weighted.mean(lifeExp, pop),
    .groups = "drop"
  )

p2 <- ggplot(summary_df, aes(x = year)) +
  geom_ribbon(aes(ymin = q25, ymax = q75, fill = continent), alpha = 0.3) +
  geom_line(aes(y = median_life, color = continent), linewidth = 1) +
  geom_line(aes(y = weighted_mean, color = continent), linetype = "dashed") +
  facet_wrap(~ continent) +
  labs(
    title = "Life Expectancy Over Time by Continent",
    x = "Year",
    y = "Life Expectancy"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("output/figure-2-ribbon-median-weighted.pdf", p2, width = 10, height = 7)
