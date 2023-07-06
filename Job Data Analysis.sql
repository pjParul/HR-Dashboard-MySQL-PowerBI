create database Job_Data_Analysis;
use Job_Data_Analysis;

select * from hr;

-- STEP 1 : DATA CLEANING
-- rename ID column name
alter table hr
change column ï»¿id emp_id varchar(20) null;

-- get columns name and their data types
describe hr;

select birthdate from hr;

set sql_safe_updates=0;  -- for security reasons only

-- birthdate is in different format, some are separated by '-' and some by '/' ; so bring them in the same format
update hr
set birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
	else null
end;

-- data type of birthdate column is text , change it to 'date'
alter table hr
modify column birthdate date;

select hire_date from hr;
-- similarly change the date format for hire_date as well
update hr
set hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
	else null
end;

alter table hr
modify column hire_date date;

-- remove time format from termdate (termination date , LWD of employee in the company)
UPDATE hr
SET termdate = STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC')
WHERE termdate IS NOT NULL AND termdate != '';

select termdate from hr;

alter table hr
modify column termdate date;  -- not able to change the data type

-- add column 'age'
alter table hr add column age INT;

update hr
set age = timestampdiff(year,birthdate,curdate());

select birthdate,age from hr;

-- find the youngest and oldest employee
select 
	min(age) as Youngest,
    max(age) as oldest
    from hr;

select count(*) from hr where age<18;

select * from hr;

alter table hr
drop column termdate;

-- DATA ANALYSIS
-- What is the gender breakdown of employees in the company?
select gender,count(*) as count from hr
where age>=18
group by gender;

-- What is the race/ethnicity breakdown of employees in the company?
select race,count(*) as Count
from hr
where age>=18
group by race
order by count(*) desc;

-- What is the age distribution of the employees in the company
select 
	min(age) as youngest,
    max(age) as oldest
from hr
where age>=18;

select 
	case 
		when age>=18 and age<=24 then '18-24'
        when age>=25 and age<=34 then '25-34'
		when age>=35 and age<=44 then '35-44'
        when age>=45 and age<=54 then '45-54'
        when age>=55 and age<=64 then '55-64'
        else '65+'
	end as Age_Group,gender,
    count(*) as Count
	from hr
    where age>=18 
    group by Age_Group,gender
    order by Age_Group,gender;
    
-- how many employees work at headquarters versus remote locations?
select * from hr;

select location,count(*) as count from hr
where age>=18
group by location;
   
--  how does the gender distribution vary across departments and job titles
select department,gender,count(*) as count from hr
where age>=18
group by department,gender
order by department;
    
-- what is the distribution of job titles across the company
select jobtitle,gender,count(*) as count from hr
where age>=18
group by jobtitle,gender
order by jobtitle;

-- which is the distribution of employees across locations by city and state?
select location_state,count(*) as count 
from hr
where age>=18 
group by location_state
order by count desc;
