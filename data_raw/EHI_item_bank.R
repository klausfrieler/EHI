library(tidyverse)
parse_audio_file <- function(audio_files){
  map_dfr(str_split(tools::file_path_sans_ext(audio_files), "_"), function(x){
    #browser()
    tibble(sentence = x[1],
           emotion = x[2],
           speaker = x[3],
           version = x[4])
  })
}


EHI_item_bank <- readxl::read_xlsx("data_raw/EHI_item_bank.xlsx")

EHI_item_bank <- EHI_item_bank %>%
  bind_cols(parse_audio_file(EHI_item_bank$audio_file)) %>%
  filter(!is.na(emotion)) %>%
  mutate(usage = "test")
print(names(EHI_item_bank))

EHI_item_bank[str_detect(EHI_item_bank$item_number, "practice"),]$usage <- "practice"
EHI_item_bank[str_detect(EHI_item_bank$item_number, "volume"),]$usage <- "volume_check"
EHI_item_bank[str_detect(EHI_item_bank$item_number, "volume"),]$emotion <- NA
EHI_item_bank[str_detect(EHI_item_bank$item_number, "volume"),]$task_group <- NA

EHI_item_bank <- EHI_item_bank %>%
  mutate(item_number = str_extract(item_number, "sad[0-9]+|angry[0-9]+|happy[0-9]+")) %>%
  group_by(sentence, emotion, speaker) %>% mutate(variant = as.integer(factor(version))) %>%
  ungroup()

usethis::use_data(EHI_item_bank, overwrite = TRUE)
