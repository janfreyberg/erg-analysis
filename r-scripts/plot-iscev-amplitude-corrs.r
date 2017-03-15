library(tidyverse)

data %>%
  filter(protocol=="iscev", datatype=="amplitude", group!="adhd") %>%
  unite(datacategory, protocol, wave, datatype, sep = ".") %>%
  spread(datacategory, value) %>%
  ggplot(mapping = aes(x = iscev.a.wave.amplitude,
                       y = iscev.b.wave.amplitude,
                       colour=group)) +
  geom_point() +
  facet_wrap(~group, nrow=1)