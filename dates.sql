create table dates (yearmonthday real);
insert into dates values ('2455198.5');
insert into dates values ('2455199.5');
insert into dates values ('2455197.5');
insert into dates values ('2455197.5' + 10);
select date(yearmonthday) from dates;