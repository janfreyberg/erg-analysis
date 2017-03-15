library(dplyr)
library(tidyr)
library(broom)
library(ggplot2)

data %>%
  filter(protocol == 'phnr', group != 'adhd') %>%
  ggplot(mapping = aes(x=group,
                       y=value,
                       color=group,
                       group=interaction(group, wave, datatype))) +
  facet_wrap(datatype ~ wave, scales="free", nrow=2) +
  theme_bw() +
  ggtitle("PHNR Protocol") +
  # geom_violin(mapping = aes(fill=group, alpha=0.2)) +
  stat_summary(fun.data="mean_se", geom="pointrange", position=position_dodge(width = 0.9))

# data %>%
#   filter(protocol == 'iscev', group != 'adhd') %>%
#   ggplot(mapping = aes(x=group,
#                        y=value,
#                        color=group,
#                        group=interaction(group, wave, datatype))) +
#   facet_wrap(datatype ~ wave, scales="free", nrow=2) +
#   theme_bw() +
#   ggtitle("ISCEV Protocol") +
#   # geom_violin(mapping = aes(fill=group, alpha=0.2)) +
#   stat_summary(fun.data="mean_se", geom="pointrange", position=position_dodge(width = 0.9))
