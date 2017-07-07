create table sensor_data (sensor_id int, temperature int, create_date date, create_time time);

HISTORICAL DATA
create external table sensor_data_realtime (sensor_id int, temperature int, time bigint)
LOCATION ('pxf://localhost:51200/kafkatest|localhost|iotstream'
'?FRAGMENTER=org.apache.hawq.pxf.api.examples.DemoKafkaFragmenter'
'&ACCESSOR=org.apache.hawq.pxf.api.examples.DemoKafkaAccessor'
'&RESOLVER=org.apache.hawq.pxf.plugins.hdfs.StringPassResolver') FORMAT 'TEXT' (DELIMITER =E',');

COMBINED DATA
create view sensor_data_all as 
  select sensor_id, temperature, create_date || ' ' || create_time create_timestamp from sensor_data
    union all
  select sensor_id, temperature, to_char(to_timestamp(time), 'YYYY-MM-DD HH24:MI:SS') from sensor_data_realtime;

STATISTICS DATA
create view sensor_stats as 
  select 1 as id, 'historical' period, sensor_id,
    count(*) as "Number of samples",
	min(temperature) as "Min Temp",
	max(temperature) as "Max Temp",
    trunc(avg(temperature)) as "Avg Temp" 
  from sensor_data
    group by sensor_id 
  union all
  select 2, 'real time', sensor_id, count(*),
	min(temperature),
	max(temperature),
    trunc(avg(temperature))
  from sensor_data_realtime
    group by sensor_id
  union all
  select 3, 'combined', sensor_id, count(*),
	min(temperature),
	max(temperature),
    trunc(avg(temperature))
  from sensor_data_all
    group by sensor_id;


select count(*) from sensor_data;
select count(*) from sensor_data_realtime;
select count(*) from sensor_data_all;
select pg_sleep(5);


select count(*) from sensor_data;
select count(*) from sensor_data_realtime;
select count(*) from sensor_data_all;
select pg_sleep(5);


select count(*) from sensor_data;
select count(*) from sensor_data_realtime;
select count(*) from sensor_data_all;
select pg_sleep(5);


select count(*) from sensor_data;
select count(*) from sensor_data_realtime;
select count(*) from sensor_data_all;
select * from sensor_stats order by 1,3;

/* CREATE EXTERNAL TABLE static */
/*     (int1 text, word text, int2 text) */
/* location ('pxf://localhost:51200/dummy_location' */
/* '?FRAGMENTER=org.apache.hawq.pxf.api.examples.DemoFragmenter' */
/* '&ACCESSOR=org.apache.hawq.pxf.api.examples.DemoAccessor' */
/* '&RESOLVER=org.apache.hawq.pxf.api.examples.DemoTextResolver') */
/* format 'text' (delimiter=E','); */
