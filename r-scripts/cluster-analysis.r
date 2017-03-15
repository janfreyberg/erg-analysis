
kmeanselbow <- function(data, krange = 1:10){
  for(i in krange){
    wss[i] <- sum(kmeans(data, i)$withinss)
  }
  return(wss)
}

set.seed(20)

wss <- c()

wss <- data %>%
  filter(group != 'adhd', datatype == 'latency', wave == 'b.wave') %>%
  spread(protocol, value) %>% rowwise %>% mutate(value = mean(c(iscev, phnr))) %>%
  mutate(group = group %>% str_replace("patient", "ASD") %>% str_replace("control", "Control") %>%
           factor(c("Control", "ASD"))) %>%
  mutate(value2=value) %>%
  mutate(value2 = ifelse(group=="ASD", (value2-29)*0.3+28.8, value2)) %>%
  mutate(value2 = ifelse(group=="Control", (value2-28.2)*0.2+28.2, value2)) %>%
  gather(sim, value, value, value2) %>%
  filter(group=="ASD" & !is.na(value)) %$%
  kmeanselbow(value)

plot(1:10, wss, type="b")