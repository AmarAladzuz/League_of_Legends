-------------------------------------------------------------------------------------------------
-- data preview------------try i po sezonama,, views uraditi

select * from Lol..champs -- nista vise
select * from Lol..matches
select * from Lol..participants
select * from Lol..stats1
select * from Lol..teambans -- nista vise
select * from Lol..teamstats

-------------------------------------------------------------------------------------------------
-- deleting unnecessary columns

alter table Lol..matches
drop column queueid, creation, version

alter table Lol..participants
drop column ss1, ss2

-------------------------------------------------------------------------------------------------
-- pick rate of champs

with champ_picks (name, total_champ_picks, total_game_picks)
as(
select name, count(name) as total_champ_picks, sum(count(name)) over() as total_game_picks from Lol..participants pa
join Lol..champs ch
on pa.championid = ch.id
group by name
)

select *, (cast(total_champ_picks as float)/cast(total_game_picks as float))*100 as pick_rate from champ_picks
order by 4 desc

-------------------------------------------------------------------------------------------------
-- Champs by win rate

-- with cte
with winning (name, win, total_wins, total_picks) 
as(
select name, win, count(name) as total_wins, sum(count(name))over(partition by name) as total_picks from Lol..stats1 st
join Lol..participants pa
on st.id = pa.matchid
join Lol..champs ch
on pa.championid = ch.id
group by name, win
)

select name, total_wins, total_picks, (cast(total_wins as float)/cast(total_picks as float))*100 as win_rate from winning
where win = 1
order by 4 desc


-- With temp table
drop table if exists #test

create table #test
(
name varchar(50),
win int,
total_wins numeric,
total_picks numeric
)

insert into #test

select name, win, count(name) as total_wins, sum(count(name))over(partition by name) as total_picks from Lol..stats1 st
join Lol..participants pa
on st.id = pa.matchid
join Lol..champs ch
on pa.championid = ch.id
group by name, win

select *, (total_wins/total_picks)*100 as win_rate from #test
where win = 1
order by 5 desc

-------------------------------------------------------------------------------------------------
-- champs ban rate 

with bans (name, champion_ban_count, total_bans)
as(
select name, count(name) as champion_ban_count, sum(count(name)) over() as total_bans from Lol..champs ch
join Lol..teambans bans
on ch.id = bans.championid
group by name
)

select *, (cast(champion_ban_count as float)/cast(total_bans as float))*100 as ban_rate from bans
order by 4 desc


-- bans by banturn

select name, banturn, count(name) as ban_count from Lol..champs ch
join Lol..teambans bans
on ch.id = bans.championid
-- where banturn = 1
group by name, banturn
order by 3 desc
-------------------------------------------------------------------------------------------------
-- number of games by platformid(server)

select platformid, count(platformid) as number_of_games from Lol..matches
group by platformid

-------------------------------------------------------------------------------------------------
-- total number of matches and total picks

select count(*) from Lol..matches
-- total matches 184.069

select count(distinct id) from Lol..participants
-- total picks 1.834.520

-------------------------------------------------------------------------------------------------
-- top picks per lane(position)

with lane_picks(position, name, pick_number, total_lane_picks)
as(
select position, name, count(name) as pick_number,  sum(count(name)) over(partition by position) as total_lane_picks from Lol..matches ma
join Lol..participants pa
on ma.id = pa.matchid
join Lol..champs ca
on pa.championid = ca.id
group by position, name
)
select *, (cast(pick_number as numeric)/cast(total_lane_picks as numeric))* 100 as lane_pick_rate from lane_picks
--where position = 'bot'
order by 5 desc