#EHI_dict_raw <- readRDS("data_raw/EHI_dict.RDS")
EHI_dict_raw <- readxl::read_xlsx("data_raw/EHI_dict.xlsx")
#names(EHI_dict_raw) <- c("key", "DE", "EN")
EHI_dict_raw <- EHI_dict_raw[,c("key", "EN", "DE","DE_F")]
EHI_dict <- psychTestR::i18n_dict$new(EHI_dict_raw)
usethis::use_data(EHI_dict, overwrite = TRUE)
