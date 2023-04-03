-- Q1- Bowlers who have bowled most deliveries and their bowling skill
SELECT b.Player_Name , c.Bowling_skill , COUNT(Bowler) as Deliveries
FROM Ball_by_Ball a 
JOIN Player b
ON a.Bowler = b.Player_Id
JOIN Bowling_Style c
ON b.Bowling_skill = c.Bowling_Id
GROUP BY Bowler , b.Player_Name , c.Bowling_skill
ORDER BY Deliveries DESC
LIMIT 10

-- Q2- Highest Wicket takers in IPL
SELECT c.Player_Name , d.Bowling_skill , count(Kind_Out) AS Wickets
FROM Wicket_Taken a 
JOIN Ball_by_Ball b 
ON a.Match_Id = b.Match_Id
AND a.Over_Id = b.Over_Id
AND a.Ball_Id = b.Ball_Id
AND a.Innings_No = b.Innings_No
JOIN Player c 
ON b.Bowler = c.Player_Id
JOIN Bowling_Style d 
ON c.Bowling_skill = d.Bowling_Id
GROUP BY c.Player_Name , d.Bowling_skill
ORDER BY Wickets DESC
LIMIT 10

-- Q3- Which Team Won The Most?
SELECT b.Team_Name , COUNT(a.Match_Winner) as wins
FROM Match a
INNER JOIN Team b
ON a.Match_Winner = b.Team_Id
GROUP BY b.Team_Id
ORDER BY wins DESC

-- Q4- Which venue has hosted the most matches in the IPL?
SELECT a.Venue_Id, b.Venue_Name , c.City_Name , COUNT(*) as matches
FROM Match a
JOIN Venue b
ON a.Venue_Id = b.Venue_Id
JOIN City c
ON b.City_Id = c.City_Id
GROUP BY a.Venue_Id , b.Venue_Name ,c.City_Name
ORDER BY matches DESC
LIMIT 10

-- Q5- Most Runs Conceded by a Bowler in an IPL Match
SELECT  a.Bowler , d.Player_Name , e.Bowling_skill ,
 SUM((COALESCE(b.Runs_Scored,0)+COALESCE(c.Extra_Runs,0))) as runs
FROM Ball_by_Ball a
LEFT JOIN  Batsman_Scored b
ON a.Match_Id = b.Match_Id
AND a.Over_Id = b.Over_Id
AND a.Ball_Id = b.Ball_Id
AND a.Innings_No = b.Innings_No
LEFT JOIN Extra_Runs c
ON a.Match_Id = c.Match_Id
AND a.Over_Id = c.Over_Id
AND a.Ball_Id = c.Ball_Id
AND a.Innings_No = c.Innings_No
JOIN Player d
ON a.Bowler = d.Player_Id
JOIN Bowling_Style e
ON d.Bowling_skill = e.Bowling_Id
GROUP BY a.Match_Id , a.Bowler , d.Player_Name
ORDER BY runs DESC
LIMIT 15

-- Q6- Rank of players in each team based on Runs Conceded by a batsman in an IPL Match
WITH x AS (
SELECT  a.Striker , g.Team_Name  , d.Player_Name , e.Bowling_skill ,
 SUM((COALESCE(b.Runs_Scored,0)+COALESCE(c.Extra_Runs,0))) as runs
FROM Ball_by_Ball a
LEFT JOIN  Batsman_Scored b
ON a.Match_Id = b.Match_Id
AND a.Over_Id = b.Over_Id
AND a.Ball_Id = b.Ball_Id
AND a.Innings_No = b.Innings_No
LEFT JOIN Extra_Runs c
ON a.Match_Id = c.Match_Id
AND a.Over_Id = c.Over_Id
AND a.Ball_Id = c.Ball_Id
AND a.Innings_No = c.Innings_No
JOIN Player d
ON a.Striker = d.Player_Id
JOIN Bowling_Style e
ON d.Bowling_skill = e.Bowling_Id
JOIN Player_Match f
ON d.Player_Id = f.Player_Id
AND a.Match_Id = f.Match_Id
JOIN Team g
ON f.Team_Id = g.Team_Id
GROUP BY  a.Match_Id , g.Team_Name , a.Striker
ORDER BY runs DESC
LIMIT 50
) 
SELECT Team_Name , Player_Name,runs , RANK() OVER (PARTITION BY Team_Name ORDER BY runs DESC) as rank_in_team
FROM x
GROUP BY Player_Name

-- Q7- Which players have hit the most sixes & Fours in IPL ?
SELECT c.Player_Name , 
SUM(CASE WHEN b.Runs_Scored = 6 THEN 1 ELSE 0 END) AS sixes, 
SUM(CASE WHEN b.Runs_Scored = 4 THEN 1 ELSE 0 END) AS fours
FROM Ball_by_Ball a 
LEFT JOIN Batsman_Scored b
ON a.Match_Id = b.Match_Id
AND a.Over_Id = b.Over_Id
AND a.Ball_Id = b.Ball_Id
AND a.Innings_No = b.Innings_No
JOIN Player c
ON a.Striker = c.Player_Id
GROUP BY a.Striker, c.Player_Name
ORDER BY sixes DESC, fours DESC
LIMIT 10

-- Q8- best economic bowler's in IPL
SELECT Player_Name,sum(coalesce(Extra_Runs,0)+Runs_Scored) as runs,
COUNT(*)/6 as overs,
ROUND((SUM(COALESCE(Extra_Runs,0)+Runs_Scored))/ROUND(count(*)/6,2),2) as economy
FROM Batsman_Scored a
JOIN Ball_by_Ball b
ON a.Match_Id=b.Match_Id
AND a.Innings_No=b.Innings_No
AND a.Over_Id=b.Over_Id
AND a.Ball_Id=b.Ball_Id
LEFT JOIN Extra_Runs c
ON a.Match_Id=c.Match_Id
AND a.Innings_No=c.Innings_No
AND a.Over_Id=c.Over_Id
AND a.Ball_Id=c.Ball_Id
JOIN Player d
ON b.Bowler=d.Player_Id
JOIN Bowling_Style e
ON d.Bowling_skill=e.Bowling_Id
GROUP BY Bowler
HAVING overs>=50
ORDER BY economy
LIMIT 10