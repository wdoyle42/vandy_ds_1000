# GET MI EXIT POLL DATA READY FOR CLASS

library(tidyverse)
load(file="Final MI.Rdata")  # load full exit poll dataset

# select relevant variables

MI_ExitPoll_Select <- select(MI_final,c(SEX,AGE10,PRSMI20,PARTYID,WEIGHT,QRACEAI,EDUC18,LGBT,BRNAGAIN,LATINOS,RACISM20,QLT20))
MI_ExitPoll_Select$SEX <- as.numeric(MI_ExitPoll_Select$SEX)
MI_ExitPoll_Select$AGE10 <- as.numeric(MI_ExitPoll_Select$AGE10)
MI_ExitPoll_Select$QRACEAI <- as.numeric(MI_ExitPoll_Select$QRACEAI)
MI_ExitPoll_Select$EDUC18 <- as.numeric(MI_ExitPoll_Select$EDUC18)
MI_ExitPoll_Select$LGBT <- as.numeric(MI_ExitPoll_Select$LGBT)
MI_ExitPoll_Select$LATINOS <- as.numeric(MI_ExitPoll_Select$LATINOS)
MI_ExitPoll_Select$RACISM20 <- as.numeric(MI_ExitPoll_Select$RACISM20)
MI_ExitPoll_Select$PRSMI20 <- as.numeric(MI_ExitPoll_Select$PRSMI20)
MI_ExitPoll_Select$BRNAGAIN <- as.numeric(MI_ExitPoll_Select$BRNAGAIN)
MI_ExitPoll_Select$preschoice <- NA
MI_ExitPoll_Select$preschoice[MI_ExitPoll_Select$PRSMI20==0] <- "Will/Did not vote for president"
MI_ExitPoll_Select$preschoice[MI_ExitPoll_Select$PRSMI20==1] <- "Joe Biden, the Democrat"
MI_ExitPoll_Select$preschoice[MI_ExitPoll_Select$PRSMI20==2] <- "Donald Trump, the Republican"
MI_ExitPoll_Select$preschoice[MI_ExitPoll_Select$PRSMI20==7] <- "Undecided/Don’t know"
MI_ExitPoll_Select$preschoice[MI_ExitPoll_Select$PRSMI20==8] <- "Refused"
MI_ExitPoll_Select$preschoice[MI_ExitPoll_Select$PRSMI20==9] <- "Another candidate"
MI_ExitPoll_Select$PARTYID <- as.numeric(MI_ExitPoll_Select$PARTYID)

MI_ExitPoll_Select$Quality <- NA
MI_ExitPoll_Select$Quality[MI_ExitPoll_Select$QLT20==1] <- "Can unite the country"
MI_ExitPoll_Select$Quality[MI_ExitPoll_Select$QLT20==2] <- "Is a strong leader"
MI_ExitPoll_Select$Quality[MI_ExitPoll_Select$QLT20==3] <- "Cares about people like me"
MI_ExitPoll_Select$Quality[MI_ExitPoll_Select$QLT20==4] <- "Has good judgment"
MI_ExitPoll_Select$Quality[MI_ExitPoll_Select$QLT20==9] <- "[DON'T READ] Don’t know/refused"
MI_ExitPoll_Select$QLT20 <- as.factor(MI_ExitPoll_Select$Quality)

MI_ExitPoll_Select <- select(MI_ExitPoll_Select,-c(Quality,LGBT,LATIONOS))

glimpse(MI_ExitPoll_Select)

MI_final_small <- MI_ExitPoll_Select

save(MI_final_small,MI_final,file="MI2020_ExitPoll.Rdata")
saveRDS("MI2020_ExitPoll_small.rds")
