library(tidyverse)
library(nbastatR)



Sys.setenv("VROOM_CONNECTION_SIZE" = 131072 * 2)

games<-game_logs(seasons=2017:2021)


game_summary<-
  games%>%
  filter(typeSeason=="Regular Season")%>%
  group_by(idGame,yearSeason, dateGame,idTeam,nameTeam,locationGame)%>%
  summarize(tov=sum(tov),
            pts=sum(pts),
            treb=sum(treb),
            oreb=sum(oreb),
            dreb=sum(dreb),
            fga=sum(fga),
            ftm=sum(ftm),
            fta=sum(fta),
            pctFG=mean(pctFG,na.rm=TRUE),
            pctFT=mean(pctFT,na.rm=TRUE),
            teamrest=max(countDaysRestTeam),
            second_game=first(isB2BSecond),
            isWin=first(isWin))%>%
  mutate(ft_80=ifelse(pctFT>.8,1,0))%>%
  group_by(idGame)%>%
  mutate(game_treb=sum(treb),
         game_oreb=sum(oreb),
         game_dreb=sum(dreb)) %>% ## Game totals
  ungroup()%>%
  group_by(idGame,yearSeason, dateGame,idTeam,nameTeam,locationGame)%>%
  mutate(opp_treb=game_treb-treb,
         opp_dreb=game_dreb-dreb,
         opp_oreb=game_oreb-oreb)%>%
  mutate(oreb_pct=oreb/(oreb+opp_dreb))%>%
  mutate(tov_pct=tov/(fga+oreb))%>%
  ungroup()


write_rds(game_summary,"game_summary.Rds")
