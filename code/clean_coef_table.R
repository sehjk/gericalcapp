# Sehj K
# April 10, 2018

library(data.table)

# Process bmi model
posh_model <- fread("data/model_coefs_posh_v2.csv", colClasses = "character")

# meds
posh_model[["coef"]] <- gsub("as.matrix\\(meds_all\\)", "Meds", posh_model[["coef"]])
# comorb
posh_model[["coef"]] <- gsub("as.matrix\\(clean_X\\)", "", posh_model[["coef"]])
# cpt ccs
posh_model[["coef"]] <- gsub("as.matrix\\(ccs_dat\\)", "", posh_model[["coef"]])
# get ccs crosswalk
cpt_ccs <- fread("data/ccs_proc_crosswalk.csv", colClasses = "character")
cpt_ccs <- unique(cpt_ccs[, 2:3])
cpt_ccs[[1]] <- paste0("cpt_class_", cpt_ccs[[1]])
# merge cpt ccs crosswalk
cpt_coefs <- posh_model[["coef"]] %in% cpt_ccs[[1]]
posh_model[["coef"]][cpt_coefs] <- merge(posh_model[, 1], cpt_ccs, by.x = "coef", by.y = "CCS")[["CCS Label"]]
# race
posh_model[["coef"]] <- gsub("PRIMARY_RACE", "Race", posh_model[["coef"]])
# column names
colnames(posh_model) <- gsub("_coefs", "", colnames(posh_model))
colnames(posh_model)

# change class
coef_cols <- which(colnames(posh_model) != "coef")
posh_model[, (coef_cols) := lapply(.SD, as.numeric), .SDcols = (coef_cols)]

saveRDS(posh_model, "data/model_coefs_posh.rds")
