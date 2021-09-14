library(nbastatR)
library(tidyverse)


Sys.setenv("VROOM_CONNECTION_SIZE" = 131072 * 2)

## All players
assign_nba_players()

## All teams
assign_nba_teams()

## Players from 2018-19
active_player_ids<-seasons_players(2019)%>%
  select(idPlayer)%>%
  as_vector()

## Drafts
draft<-drafts(draft_years=1990:2020)

## Get all career data on players
## This takes a long time to run!
get_nba_data<-FALSE

if (get_nba_data){
i <- 1
pc<-NULL
while(i<length(active_player_ids)){
pc_sub<-players_careers(player_ids =  active_player_ids[i:(i+9)],modes="Totals")

print(paste("Completed sequence", i, ":",  (i+9 )))

pc<-bind_rows(pc,pc_sub)

i<- (i+10)
}
}
write_rds(pc,"player_careers.Rds")

pc<-readRDS("player_careers.Rds")





pc_full <-
  pc %>%
  filter(nameTable == "SeasonTotalsRegularSeason") %>%
  unnest(cols = c(dataTable)) %>%
  filter(slugSeason == "2018-19") %>%
  select(-nameTable, -modeSearch) %>%
  group_by(idPlayer)%>%
  add_count()%>%
  filter(n==1)


pc_first_team <-
  pc %>%
  filter(nameTable == "SeasonTotalsRegularSeason") %>%
  unnest(cols = c(dataTable)) %>%
  filter(slugSeason == "2018-19") %>%
  select(-nameTable, -modeSearch) %>%
  group_by(idPlayer)%>%
  add_count()%>%
  filter(n>1)%>%
  summarize(slugTeam=first(slugTeam))

pc_move <-
    pc %>%
    filter(nameTable == "SeasonTotalsRegularSeason") %>%
    unnest(cols = c(dataTable)) %>%
    filter(slugSeason == "2018-19") %>%
    select(-nameTable, -modeSearch) %>%
    group_by(idPlayer)%>%
    filter(slugTeam=="TOT")

pc_move$slugTeam=pc_first_team$slugTeam


pc_season <- full_join(pc_full, pc_move) %>%
  left_join(draft %>% select(idPlayer,
                             nameOrganizationFrom,
                             locationOrganizationFrom),
            by = "idPlayer") %>%
  left_join((
     df_dict_nba_teams %>%
      filter(isNonNBATeam == 0) %>%
      select(slugTeam, idConference)
  ),
  by = "slugTeam") %>%
  mutate(idConference = ifelse(idConference == 0, 1, idConference)) %>%
  rename(org = nameOrganizationFrom) %>%
  rename(country = locationOrganizationFrom)%>%
  ungroup()%>%
  mutate(org=fct_lump_min(org,min=2))


write_rds(pc_season,"nba_players_2018.Rds")
