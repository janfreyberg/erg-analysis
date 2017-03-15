library(tidyverse)

data %>%
  filter(protocol=="phnr", datatype=="amplitude", group!="adhd") %>%
  unite(datacategory, wave, datatype, sep = ".") %>%
  spread(datacategory, value) %>%
  ggplot(mapping = aes(x = a.wave.amplitude,
                       y = b.wave.amplitude,
                       colour=group)) +
  geom_point() +
  facet_wrap(~group, nrow=1)