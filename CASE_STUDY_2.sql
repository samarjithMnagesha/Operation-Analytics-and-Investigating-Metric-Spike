drop database if exists Casestudy_2;
create database `Casestudy_2`;
use `Casestudy_2`;

-- users table
create table `users`(
user_id int,
created_at varchar(100),
company_id int,
language varchar(50),
activated_at varchar(100),
state varchar(50)
);
show variables like 'secure_file_priv';
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv"
into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

alter table users add column temp_created_at datetime;
update users set temp_created_at = str_to_date(created_at ,'%d-%m-%Y %H:%i');
alter	table users drop column created_at;
alter table users change column temp_created_at created_at datetime;

alter table users add column temp_activated_at datetime;
update users set temp_activated_at = str_to_date(activated_at ,'%d-%m-%Y %H:%i');
alter	table users drop column activated_at;
alter table users change column temp_activated_at activated_at datetime;

-- users table
drop table if exists events;
create table `events`(
user_id	int ,
occurred_at varchar(100),
event_type varchar(50),
event_name varchar(100),
location varchar(50),
device varchar(50),
user_type int
);
show variables like 'secure_file_priv';
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/events.csv"
into table events
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

alter table events add column temp_occurred_at datetime;
update events set temp_occurred_at = str_to_date(occurred_at ,'%d-%m-%Y %H:%i');
alter	table events drop column occurred_at;
alter table events change column temp_occurred_at occurred_at datetime;


-- email table

create table `email_events`(
user_id	int,
occurred_at	varchar(100),
action varchar(100),	
user_type int
);
show variables like 'secure_file_priv';
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/email_events.csv"
into table email_events
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

alter table email_events add column temp_occurred_at datetime;
update email_events set temp_occurred_at = str_to_date(occurred_at ,'%d-%m-%Y %H:%i');
alter	table email_events drop column occurred_at;
alter table email_events change column temp_occurred_at occurred_at datetime;

-- Weekly User Engagement:
SELECT
    DATE_ADD(created_at, INTERVAL -WEEKDAY(created_at) DAY) AS week_start_date,
    COUNT(DISTINCT user_id) AS active_users_count
FROM
    users
GROUP BY
    week_start_date;

-- User Growth Analysis:    
SELECT
    DATE_ADD(created_at, INTERVAL -DAYOFMONTH(created_at) + 1 DAY) AS month_start_date,
    COUNT(DISTINCT user_id) AS total_users
FROM users
GROUP BY month_start_date
ORDER BY month_start_date;

-- Weekly Retention Analysis:
WITH user_signups AS (
    SELECT
        user_id,
        DATE_ADD(created_at, INTERVAL -WEEKDAY(created_at) DAY) AS signup_week
    FROM users
),
user_activity AS (
    SELECT
        user_id,
        DATE_ADD(occurred_at, INTERVAL -WEEKDAY(occurred_at) DAY) AS activity_week
    FROM events
)
SELECT
    us.signup_week AS cohort_week,
    ua.activity_week AS retention_week,
    COUNT(DISTINCT ua.user_id) AS retained_users
FROM user_signups us
LEFT JOIN
    user_activity ua ON us.user_id = ua.user_id AND ua.activity_week >= us.signup_week
GROUP BY
    us.signup_week, ua.activity_week
ORDER BY
    us.signup_week, ua.activity_week;


-- Weekly Engagement Per Device:
SELECT
    DATE_ADD(occurred_at, INTERVAL -WEEKDAY(occurred_at) DAY) AS week_start_date,
    device,
    COUNT(DISTINCT user_id) AS active_users_count
FROM events
GROUP BY week_start_date, device
ORDER BY week_start_date, device;

-- Email Engagement Analysis:
SELECT
    action,
    COUNT(DISTINCT user_id) AS unique_users_count,
    COUNT(*) AS total_actions_count
FROM
    email_events
GROUP BY action
ORDER BY action;
