library(tidyverse)
library(nbastatR) ## You'll need to get this library

Sys.setenv("VROOM_CONNECTION_SIZE" = 131072 * 2)

games<-game_logs(seasons=2017:2019)

game_summary<-games%>%
  filter(typeSeason=="Regular Season")%>%
  group_by(idGame,yearSeason, dateGame,idTeam,nameTeam,locationGame)%>%
  summarize(tov=sum(tov),
            pts=sum(pts),
            treb=sum(treb),
            pctFG=mean(pctFG,na.rm=TRUE),
            teamrest=max(countDaysRestTeam),
            second_game=first(isB2BSecond),
            pctFT=mean(pctFT,na.rm=TRUE),
            isWin=first(isWin))%>%
  mutate(ft_80=ifelse(pctFT>.8,1,0))%>%
  ungroup()

write_rds(game_summary,"game_summary.Rds")
