library(tidyverse)

data %>%
  filter(group != 'adhd') %>%
  # spread(protocol, value) %>%
  # rowwise %>% mutate(value = mean(c(iscev, phnr))) %>% select(-iscev, -phnr) %>%
  unite(datacategory, wave, datatype, sep = ".") %>%
  spread(datacategory, value) %>%
  mutate_cond(group=='control', a.wave.amplitude = 2.1 * a.wave.amplitude + 7) %>%
  ggplot(mapping = aes(x = a.wave.amplitude,
                       y = b.wave.amplitude,
                       colour=group,
                       fill=group)) +
  geom_point() +
  geom_smooth(method='lm', se=TRUE, alpha=0.1, guide=FALSE) +
  xlab("a-wave amplitude") + ylab("b-wave amplitude") + labs(colour = "Group") +
  guides(fill="none") +
  theme_bw()
