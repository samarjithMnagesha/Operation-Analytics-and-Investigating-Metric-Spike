create database casestudy_1;
CREATE TABLE job_data
(
    ds DATE,
    job_id INT NOT NULL,
    actor_id INT NOT NULL,
    event VARCHAR(15) NOT NULL,
    language VARCHAR(15) NOT NULL,
    time_spent INT NOT NULL,
    org CHAR(2)
);

INSERT INTO job_data (ds, job_id, actor_id, event, language, time_spent, org)
VALUES ('2020-11-30', 21, 1001, 'skip', 'English', 15, 'A'),
    ('2020-11-30', 22, 1006, 'transfer', 'Arabic', 25, 'B'),
    ('2020-11-29', 23, 1003, 'decision', 'Persian', 20, 'C'),
    ('2020-11-28', 23, 1005,'transfer', 'Persian', 22, 'D'),
    ('2020-11-28', 25, 1002, 'decision', 'Hindi', 11, 'B'),
    ('2020-11-27', 11, 1007, 'decision', 'French', 104, 'D'),
    ('2020-11-26', 23, 1004, 'skip', 'Persian', 56, 'A'),
    ('2020-11-25', 20, 1003, 'transfer', 'Italian', 45, 'C');

-- Jobs Reviewed Over Time:    
SELECT DATE(ds) AS review_date,
       COUNT(*) AS jobs_reviewed_per_hour
FROM job_data
WHERE ds between '2020-11-01' and '20-11-30'
GROUP BY review_date
ORDER BY review_date;

-- Throughput Analysis:
SELECT ds,
       time_spent,
       AVG(time_spent)
       OVER (ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_7_day_average
FROM job_data;

-- Language Share Analysis:
select language, count(distinct language),
    round(100*count(*)/(select count(*) from job_data),2) as percentage_share
from job_data
group by language order by language desc;

-- Duplicate Rows Detection:
select *
from
(select *,
row_number() over(partition by ds,actor_id,job_id) as row_num
from job_data) a
where row_num>1;
