use [UEFA]
GO
/*
create table teams(
id int NOT NULL,
team_name varchar(50) not null,
country varchar(50) not null,
home_stadium_id INT NOT NULL,
PRIMARY KEY (id),
FOREIGN KEY (home_stadium_id) REFERENCES stadiums(id)

);

create table stadiums(
id int NOT NULL,
name varchar(50) not null,
city varchar(50) not null,
country varchar(50) not null,
capacity int not null
PRIMARY KEY (id),


);

create table players(
player_id varchar(7) NOT NULL,
first_name varchar(50) ,
last_name varchar(50) not null,
nationality varchar(50) not null,
dob Date not null,
team_id int ,
JERSEY_NUMBER int ,
position varchar(25) not null,
player_height int ,
player_weight int ,
player_foot varchar(1),


PRIMARY KEY (player_id),
FOREIGN KEY (team_id) REFERENCES teams(id)
);

create table managers(
manager_id int NOT NULL,
first_name varchar(50) ,
last_name varchar(50) not null,
nationality varchar(50) not null,
dob Date not null,
team_id int ,

PRIMARY KEY (manager_id),
FOREIGN KEY (team_id) REFERENCES teams(id)
);

create table Matches(
match_id varchar(5) NOT NULL,
season VARCHAR(9) NOT NULL,
Date_time varchar(50) NOT NULL,
home_team_id int not null,
nationality varchar(50) not null,
dob Date not null,
team_id int ,

PRIMARY KEY (match_id),
FOREIGN KEY (team_id) REFERENCES teams(id)
);

create table Goals(
match_id varchar(5) NOT NULL,
goal_id varchar(5) NOT NULL,
PID VARCHAR(9) NOT NULL, // player id
Duration int,
ASSIST VARCHAR(9),
Goal_DESC varchar(255),

PRIMARY KEY (goal_id),
FOREIGN KEY (match_id) REFERENCES matches(match_id),
FOREIGN KEY (PID) REFERENCES players(id),
FOREIGN KEY (ASSIST) REFERENCES players(id),


);*/

--EASY
--q1
select distinct p.PLAYER_ID,p.FIRST_NAME,p.LAST_NAME from players$ p , managers$ m
where p.TEAM_ID = m.TEAM_ID and m.FIRST_NAME='pep'

--q2
select  matches$.Match_id, matches$.season, matches$.DATE_TIME, matches$.STADIUM_ID, COUNTRY
from matches$
inner join stadiums$ on matches$.STADIUM_ID = stadiums$.ID
where stadiums$.COUNTRY = 'Russia'

--q3
select distinct t.TEAM_NAME,count(*) as wins from teams$ t,matches$ m
where m.HOME_TEAM_SCORE > m.AWAY_TEAM_SCORE and m.HOME_TEAM_ID=t.ID  
group by t.TEAM_NAME  having count(*) > 3

--q4 
select 
teams$.TEAM_NAME, teams$.COUNTRY, managers$.NATIONALITY as Manager_Country
from teams$
inner join managers$ on teams$.id = managers$.TEAM_ID
where managers$.nationality != teams$.Country

--q5
select  matches$.Match_id, matches$.season, matches$.DATE_TIME, matches$.STADIUM_ID,CAPACITY, COUNTRY
from matches$
inner join stadiums$ on matches$.STADIUM_ID = stadiums$.ID
where stadiums$.CAPACITY > 60000

--MEDIUM
--q6
select FIRST_NAME, LAST_NAME, GOAL_ID, GOAL_DESC, ASSIST, HEIGHT, DATE_TIME
from goals$
inner join players$ on goals$.PID = players$.PLAYER_ID
inner join matches$ on goals$.MATCH_ID = matches$.MATCH_ID

where players$.HEIGHT > 180
AND  goals$.ASSIST is NULL
AND matches$.DATE_TIME like '%%-%%%-20%'




--q7
SELECT team_name, total_home_matches, home_wins, win_percentage
FROM (
  SELECT teams$.team_name, 
    COUNT(matches$.home_team_id) AS total_home_matches, 
    SUM(CASE WHEN matches$.home_team_score > matches$.away_team_score THEN 1 ELSE 0 END) AS home_wins,
(SUM(CASE WHEN matches$.home_team_score > matches$.away_team_score THEN 1 ELSE 0 END) * 100.0 / COUNT(matches$.home_team_id)) AS win_percentage
  FROM teams$
  INNER JOIN matches$ ON teams$.id = matches$.home_team_id
  WHERE teams$.country = 'Russia'
  GROUP BY teams$.team_name, teams$.id
) AS subquery
WHERE win_percentage < 50; -- cant use this inside where clause, so had to make it sub-query

--q8
SELECT s.NAME AS stadium_name, COUNT(*) AS total_matches, 
       SUM(CASE WHEN m.HOME_TEAM_ID = t.id AND m.HOME_TEAM_SCORE > m.AWAY_TEAM_SCORE THEN 1 ELSE 0 END) AS home_wins, 
       SUM(CASE WHEN m.HOME_TEAM_ID = t.id THEN 1 ELSE 0 END) AS total_home_matches, 
       (SUM(CASE WHEN m.HOME_TEAM_ID = t.id AND m.HOME_TEAM_SCORE > m.AWAY_TEAM_SCORE THEN 1 ELSE 0 END) / 
        CAST(SUM(CASE WHEN m.HOME_TEAM_ID = t.id THEN 1 ELSE 0 END) AS FLOAT)) AS win_percentage
FROM matches$ m
JOIN teams$ t ON m.HOME_TEAM_ID = t.id OR m.AWAY_TEAM_ID = t.id
JOIN stadiums$ s ON m.stadium_id = s.id
GROUP BY s.NAME
HAVING COUNT(*) > 6 AND 
       (SUM(CASE WHEN m.HOME_TEAM_ID = t.id AND m.HOME_TEAM_SCORE > m.AWAY_TEAM_SCORE THEN 1 ELSE 0 END) / 
        CAST(SUM(CASE WHEN m.HOME_TEAM_ID = t.id THEN 1 ELSE 0 END) AS FLOAT)) < 0.5;

/*-------q9-----------*/
select top(1) m.SEASON,count(*) as most_goals_by_left_foot
from matches$ m,goals$ g 
where g.GOAL_DESC = 'left-footed shot' and m.MATCH_ID=g.MATCH_ID
group by m.SEASON 
order by most_goals_by_left_foot desc

/*-----q10-----*/
select top(1) p.NATIONALITY,count(distinct p.PLAYER_ID) as goals_by_player 
from players$ p, goals$ g
where p.PLAYER_ID=g.PID 
group by p.NATIONALITY
having count(distinct p.PLAYER_ID) > 1 
order by goals_by_player desc

/*-------Q11----------*/
select distinct S.NAME,COUNT(g.GOAL_DESC ) AS total_shot,
sum(case when g.goal_desc='left-footed shot' then 1 else 0 end) as left_foot,
sum(case when g.goal_desc='right-footed shot' then 1 else 0 end) as right_foot
from stadiums$ s,matches$ m,goals$ g
where (g.MATCH_ID=m.MATCH_ID  and m.STADIUM_ID = s.ID) 
group by S.NAME
having sum(case when g.goal_desc='left-footed shot' then 1 else 0 end)> sum(case when g.goal_desc='right-footed shot' then 1 else 0 end)

--q12
select matches$.MATCH_ID,  matches$.DATE_TIME,  stadiums$.CAPACITY, stadiums$.COUNTRY 
from matches$
join stadiums$ on  matches$.STADIUM_ID = stadiums$.ID 
where stadiums$.COUNTRY = (
		select stadiums$.COUNTRY -- condition to pick stadium with max_cumulativeCAPACITY
		from stadiums$
		group by stadiums$.COUNTRY
		having sum(stadiums$.CAPACITY) = (select max(grped_cumulative_capacity.cumulative_capacity) as MAX_cumulative_capacity
										 from ( select stadiums$.COUNTRY, sum(stadiums$.CAPACITY) as cumulative_capacity
												from stadiums$
												group by stadiums$.COUNTRY ) as grped_cumulative_capacity)
							)
order by matches$.DATE_TIME desc		-- Matches played earliest first

--q13
select CONCAT(p1.LAST_NAME ,' and ',p2.LAST_NAME) as player_duo,concat(p1.player_id ,' and ',p2.player_id) as player_duos_ids,
count(*) as goal_assist_comb
from matches$ m
join goals$ g1 on m.MATCH_ID = g1.MATCH_ID
join goals$ g2 on m.MATCH_ID = g2.MATCH_ID 
join players$ p1 on g1.PID=p1.PLAYER_ID
join players$ p2 on g2.PID =p2.PLAYER_ID
where (g1.ASSIST = p2.PLAYER_ID and g2.ASSIST =p1.PLAYER_ID and p1.PLAYER_ID != p2.PLAYER_ID )
group by p1.LAST_NAME,p2.last_NAME,p1.PLAYER_ID,p2.PLAYER_ID
order by goal_assist_comb desc

--q14
SELECT top 1 teams$.ID, teams$.TEAM_NAME,teams$.COUNTRY,
     COUNT(*) AS total_goals,
     SUM(CASE WHEN goals$.GOAL_DESC = 'header' THEN 1 ELSE 0 END) AS header_goals,
     (SUM(CASE WHEN goals$.GOAL_DESC = 'header' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS header_goal_percentage
     FROM teams$
     JOIN matches$ ON teams$.ID = matches$.AWAY_TEAM_ID
     JOIN goals$ ON matches$.MATCH_ID = goals$.MATCH_ID
     where matches$.DATE_TIME like '%%-%%%-20%' -- condition for year
     GROUP BY teams$.ID, teams$.TEAM_NAME,teams$.COUNTRY,teams$.HOME_STADIUM_ID
     ORDER BY header_goal_percentage DESC;

--q15
Select TOP(1) mang.FIRST_NAME,mang.LAST_NAME ,t.TEAM_NAME,count(*) as wins 
from teams$ t,matches$ m,managers$ mang
where 
((m.HOME_TEAM_SCORE > m.AWAY_TEAM_SCORE and m.HOME_TEAM_ID=t.ID and mang.TEAM_ID=t.id) or 
(m.AWAY_TEAM_SCORE> m.HOME_TEAM_SCORE and m.AWAY_TEAM_ID=t.id and 
mang.TEAM_ID=t.ID ))
group by mang.FIRST_NAME,mang.LAST_NAME,t.TEAM_NAME  
ORDER BY wins DESC


