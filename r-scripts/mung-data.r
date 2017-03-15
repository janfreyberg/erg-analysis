
# Find latest file
current.file <- tail(list.files(pattern='*.csv'), n=1)

data <- read_csv(current.file)

# Reshape the data
data %<>%
  gather(variable, value, -id, -eye, -group) %>%
  separate(variable, c('protocol', 'wave', 'datatype'), sep=' ') %>%
  mutate(wave = paste(wave, "wave", sep="."))

# New data frame: Latency
latency.data <- data %>%
  filter(datatype=='latency')
# New data frame: Amplitude
amplitude.data <- data %>%
  filter(datatype=='amplitude')
# New data frame: AB ratio
ratio.data <- amplitude.data %>%
  spread(wave, value) %>%
  mutate(value=a.wave/b.wave) %>%
  mutate(datatype='ratio')
