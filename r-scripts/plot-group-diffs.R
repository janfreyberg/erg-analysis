
data %>%
  filter(group != 'adhd') %>%
  spread(protocol, value) %>% rowwise %>% mutate(value = mean(c(iscev, phnr))) %>%
  ggplot(mapping = aes(x=group,
                       y=value,
                       color=group,
                       group=interaction(group, wave, datatype))) +
    facet_wrap(datatype ~ wave, scales="free", nrow=2) +
    theme_bw() +
    ggtitle("All Data") +
    stat_summary(fun.data="mean_se", geom="pointrange", position=position_dodge(width = 0.9)) +
    stat_summary(fun.data="mean_se", geom="errorbar", width=0.1) +
    geom_point(aes(y=value), position=position_jitterdodge(jitter.width=0.3), shape=1)

