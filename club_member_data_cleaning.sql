-- TASKS --
/*
1. Create a key id. COMPLETED
2. Remove special characters, ensure all entries are lowercase and free of extra whitespace. COMPLETED
3. Separate full name to individual columns (firstname, last_name). COMPLETED
4. Some ages have an extra digit at the end only show the first 2 digits. COMPLETED
5. Email addresses are unique. Use this column when searching for duplicates and remove duplicate entries. COMPLETED
6. Convert all empty fields to NULL. COMPLETED
7. Separate address to three different columns (street_address, city, state) COMPLETED
8. All membership_date were in the 2000's. COMPLETED
*/

use pvpit;

select * from club_member_info;


-- check for null values
select *
from club_member_info
where full_name is null or age is null or martial_status is null or phone is null or full_address is null or job_title is null or membership_date is null; 



-- remove empty spaces from martial_status
select *
from club_member_info
where martial_status=""; 

select count(1)
from club_member_info
where martial_status=""; 

update club_member_info
set martial_status="NULL"
where martial_status="";


select *
from club_member_info
where age="";

select *
from pvpit.club_member_info
where full_name="";

select *
from pvpit.club_member_info
where email="";

select *
from pvpit.club_member_info
where phone="";

select *
from club_member_info
where full_address="";

-- remove empty spaces from job_title
select *
from club_member_info
where job_title="";

select count(1)
from club_member_info
where job_title="";

update club_member_info
set job_title="NULL"
where job_title="";

select *
from club_member_info
where membership_date="";



-- Some ages have an extra digit at the end, show only the first 2 digits.
select count(1) from club_member_info where age > 120;

select age, substring(age, 1, 2)
from club_member_info
where age > 120;

update club_member_info
set age=substring(age, 1, 2)
where age>120;



-- Remove special characters, ensure all entries are lowercase and free of extra whitespace
select lower(trim(full_name)) from club_member_info;

update club_member_info
set full_name=lower(trim(full_name)), martial_status=lower(trim(martial_status)), email=trim(email), full_address=lower(trim(full_address)), job_title=lower(trim(job_title));

select full_name, replace(full_name, "?", "") from club_member_info;

update club_member_info
set full_name=replace(full_name, "?", "");

alter table club_member_info
rename column martial_status to marital_status;



-- Separate full name to individual columns (firstname, last_name)
select substring_index(full_name, " ", 1) as first_name from club_member_info;

alter table club_member_info
add column first_name varchar(100);

update club_member_info
set first_name=substring_index(full_name, " ", 1);

select substr(full_name, locate(" ", full_name)) as last_name from club_member_info;

alter table club_member_info
add column last_name varchar(100);

update club_member_info
set last_name=substr(full_name, locate(" ", full_name));

alter table club_member_info
drop column full_name;


-- attempt to delete duplicates
select count(distinct email) from club_member_info;

select full_name, email, membership_date, count(email) 
from club_member_info
group by email
having count(email) > 1;

select * from club_member_info where email = "ehuxterm0@marketwatch.com";

with rank_cte as (
select *, row_number() over (partition by email order by phone) as r
from club_member_info
)
delete from club_member_info
where phone in (select phone from rank_cte where r>1);



-- create key id
with rn_cte as (
select *, row_number() over(order by phone) as r 
from club_member_info
)
select * into cleaned_club_member_info from rn_cte;

insert into cleaned_club_member_info
select *, row_number() over(order by phone) from club_member_info;

	-- simple solution
alter table club_member_info
add column member_id int auto_increment primary key;

delete from club_member_info where member_id is null;

truncate table cleaned_club_member_info;

alter table cleaned_club_member_info
add column member_id int;



-- all membership_dates were in 2000's
select membership_date from club_member_info where membership_date like "%20__"; 

select membership_date from club_member_info where membership_date like "%19__"; 

delete from club_member_info where membership_date like "%19__";



-- Separate address to three different columns (street_address, city, state)
select full_address from club_member_info;

select substring_index(full_address, ",", -2) from club_member_info;

select full_address, substring_index(full_address, ",", 1) as street, substring_index(substring_index(full_address, ",", -2),",",1) as city, substring_index(full_address, ",", -1) as state from club_member_info;

alter table club_member_info
add column street varchar(70);

update club_member_info
set street=substring_index(full_address, ",", 1);

alter table club_member_info
add column city varchar(25);

update club_member_info
set city=substring_index(substring_index(full_address, ",", -2),",",1);

alter table club_member_info
add column state varchar(25);

update club_member_info
set state=substring_index(full_address, ",", -1);

alter table club_member_info
drop column full_address;
