library(dplyr)
library(tidyr)
library(broom)
library(corrr)
library(boot)

# Run a number of tests and slot them into tidy tibbles
ts.amplitude <- amplitude.data %>%
  group_by(interaction(wave, protocol)) %>%
  do(tidy(t.test(filter(., group=='patient')$value, filter(., group=='control')$value)))

ts.ratio <- ratio.data %>%
  group_by(interaction(protocol)) %>%
  do(tidy(t.test(filter(., group=='patient')$value, filter(., group=='control')$value)))


# Run anova on latency
aovs <- data %>%
  group_by(datatype) %>%
  filter(group=='control' | group=='patient') %>%
  do(tidy(
    aov(value ~ group*protocol*wave + Error(id/(protocol*wave)), data=.)
    )) %>%
  # remove all terms that don't include group
  filter(grepl("group", term))

# Run a correlation between a wave amplitude and b wave latency
corrs.asd <- data %>%
  unite(datacategory, protocol, wave, datatype, sep = " ") %>%
  spread(datacategory, value) %>%
  filter(group=="patient") %>%
  select(-eye, -group, -id) %>%
  correlate() %>%
  shave() %>%
  stretch(na.rm = TRUE) %>%
  mutate(group="patient")

corrs.control <- data %>%
  unite(datacategory, protocol, wave, datatype, sep = " ") %>%
  spread(datacategory, value) %>%
  filter(group=="control") %>%
  select(-eye, -group, -id) %>%
  correlate() %>%
  shave() %>%
  stretch(na.rm = TRUE) %>%
  mutate(group="control")

corrs <- full_join(corrs.control, corrs.asd) %>%
  mutate(z.transform = atanh(r))

# Test the differences using fisher's z
fisher.z <- function(r1, r2, n1, n2){
    z <- (atanh(r1) - atanh(r2)) /
          ((1/(n1-3))+(1/(n2-3)))^0.5

      test.list <- list(
      p.value = 2*(1-pnorm(abs(z))),
      estimate = r1 - r2, method = "fisher.z",
      alternative = "two.sided",
      estimate1 = r1, estimate2 = r2
      )
      class(test.list) <- "htest"
      return(test.list)
}

corr.tests <- corrs %>%
  group_by(interaction(x, y)) %>%
    do(tidy(
    fisher.z(
      filter(., group=="control")$r,
      filter(., group=="patient")$r,
      data %>% filter(group=="control") %>% select(id) %>% unique() %>% nrow(),
      data %>% filter(group=="patient") %>% select(id) %>% unique() %>% nrow()
    )
  ))


# #Test Difference using bootstrap (currently sample too small)
# bootcorr.con <- data %>%
#   unite(datacategory, protocol, wave, datatype, sep = ".") %>%
#   spread(datacategory, value) %>%
#   filter(group=="control") %>%
#   # drop non-numeric values for cor()
#   select(-eye, -id, -group) %>%
#   # Bootstrap with broom, then correlate
#   bootstrap(10000) %>%
#   do(tidy(
#     cor(., use="pairwise.complete.obs", method="spearman")
#   )) %>%
#   # reshape so rownames and colnames are factors
#   gather(.colnames, correlation, -replicate, -.rownames) %>%
#   # Add the group variable back in
#   mutate(group = "control")
# 
# bootcorr.asd <- data %>%
#   unite(datacategory, protocol, wave, datatype, sep = ".") %>%
#   spread(datacategory, value) %>%
#   filter(group=="patient") %>%
#   # drop non-numeric values for cor()
#   select(-eye, -id, -group) %>%
#   # Bootstrap with broom, then correlate
#   bootstrap(10000) %>%
#   do(tidy(
#     cor(., use="pairwise.complete.obs", method="spearman")
#   )) %>%
#   # reshape so rownames and colnames are factors
#   gather(.colnames, correlation, -replicate, -.rownames) %>%
#   # Add the group variable back in
#   mutate(group = "patient")
# 
# bootcorr <- full_join(bootcorr.asd, bootcorr.con)
# 
# 
# bootcorr.test <-  bootcorr %>%
#   filter(.rownames != .colnames) %>%
#   group_by(interaction(.rownames, .colnames)) %>%
#   do(tidy(
#     t.test(
#       x = filter(., group=="control")$correlation,
#       y = filter(., group=="patient")$correlation
#     )
#   ))
