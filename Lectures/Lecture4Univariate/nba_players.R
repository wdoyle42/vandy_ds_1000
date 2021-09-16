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

## Only run if I'm sure I want to
if (get_nba_data){
i <- 1
pc<-NULL
## The interface was giving me fits, so this runs it in chunks so I can restart if necessary. 
while(i<length(active_player_ids)){
pc_sub<-players_careers(player_ids =  active_player_ids[i:(i+9)],modes="Totals")

print(paste("Completed sequence", i, ":",  (i+9 )))

pc<-bind_rows(pc,pc_sub)

i<- (i+10)
}
}

## Write full dataset
write_rds(pc,"player_careers.Rds")

## read full dataset
pc<-readRDS("player_careers.Rds")


## This gets data for players who played the whole year on one team. 

pc_full <-
  pc %>%
  filter(nameTable == "SeasonTotalsRegularSeason") %>% ## Just get regular season totals
  unnest(cols = c(dataTable)) %>% ## expand regular season data 
  filter(slugSeason == "2018-19") %>% # just 2018
  select(-nameTable, -modeSearch) %>% #drop some metadata
  group_by(idPlayer)%>%  
  add_count()%>% ## count the number of times the player shows up
  filter(n==1)  ## filter for just one row

## This gets data for players who changed teams during the season and assigns a team to them. 
pc_first_team <-
  pc %>%
  filter(nameTable == "SeasonTotalsRegularSeason") %>%
  unnest(cols = c(dataTable)) %>%
  filter(slugSeason == "2018-19") %>%
  select(-nameTable, -modeSearch) %>%
  group_by(idPlayer)%>%
  add_count()%>%
  filter(n>1)%>%
  summarize(slugTeam=first(slugTeam)) ## assign first team played as season team, better to use team with most games.
# This selects the data for players who moved teams (team=TOT)
pc_move <-
    pc %>%
    filter(nameTable == "SeasonTotalsRegularSeason") %>%
    unnest(cols = c(dataTable)) %>%
    filter(slugSeason == "2018-19") %>%
    select(-nameTable, -modeSearch) %>%
    group_by(idPlayer)%>%
    filter(slugTeam=="TOT")

## Replace team=TOT with 1st team
pc_move$slugTeam=pc_first_team$slugTeam

## Putting it all together. 
pc_season <- full_join(pc_full, pc_move) %>% ## Join the two player datasets
  left_join(draft %>% select(idPlayer,
                             nameOrganizationFrom,
                             locationOrganizationFrom),
            by = "idPlayer") %>% ## join draft information
  left_join((
     df_dict_nba_teams %>%
      filter(isNonNBATeam == 0) %>%
      select(slugTeam, idConference)
  ),
  by = "slugTeam") %>% ## join team information
  mutate(idConference = ifelse(idConference == 0, 1, idConference)) %>% ## some weirdness <shrug>
  rename(org = nameOrganizationFrom) %>% 
  rename(country = locationOrganizationFrom)%>%
  ungroup()%>%
  mutate(org=fct_lump_min(org,min=2))


write_rds(pc_season,"nba_players_2018.Rds")
