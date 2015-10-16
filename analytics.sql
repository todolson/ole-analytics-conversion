drop table uc_analdummy
go
drop table uc_analreal
go

CREATE TABLE uc_analdummy
LIKE ole_ds_item_t
GO

CREATE TABLE uc_analreal
LIKE ole_ds_item_t
GO


insert uc_analdummy
select * from ole_ds_item_t
where barcode like "A%"
go

insert uc_analreal
select * from ole_ds_item_t
where barcode in
(SELECT substring(barcode,2) FROM uc_analdummy)
GO


create table uc_analitemupdates
(ITEM_ID int(11) NOT NULL,
HOLDINGS_ID int(11) NOT NULL)
GO
insert uc_analitemupdates
select a.item_id, b.holdings_id 
from uc_analreal a, uc_analdummy b
where a.BARCODE = substring( b.BARCODE,2)
GO
CREATE TABLE uc_analitemholdings
  ( 
	ITEM_HOLDINGS_ID	int(11) NULL,
	HOLDINGS_ID     	int(11) NOT NULL,
	ITEM_ID         	int(11) NOT NULL)
GO
insert uc_analitemholdings
select item_id, holdings_id, item_id
from uc_analreal 
GO
/* ABOVE MAY BE WRONG. TRYING TO USE THE ITEM ID AS ITEM HOLDINGS ID. IT MAY BE BETTER TO GENERATE IT SEPARATELY */

update ole_ds_item_t i join uc_analitemupdates a on i.ITEM_ID = a.ITEM_ID set i.HOLDINGS_ID = a.HOLDINGS_ID;

/*
These statements aren't used because I don't need the second table
update UC_ANALITEMHOLDINGS2 i join uc_analitemholdings a on i.ITEM_HOLDINGS_ID = a.ITEM_HOLDINGS_ID set i.HOLDINGS_ID = a.HOLDINGS_ID;

update UC_ANALITEMHOLDINGS2 i join uc_analitemholdings a on i.ITEM_HOLDINGS_ID = a.ITEM_HOLDINGS_ID set i.ITEM_ID = a.ITEM_ID;

7 ROWS ARE DUPS ON THE ID BECAUSE THEY MUST HAVE BEEN MADE SINCE WE PUT UP OLE
*/
CREATE TABLE uc_analitemholdingsDUP
  ( 
	ITEM_HOLDINGS_ID	int(11) NULL,
	HOLDINGS_ID     	int(11) NOT NULL,
	ITEM_ID         	int(11) NOT NULL)
GO

insert uc_analitemholdingsDUP
SELECT a.* 
FROM uc_analitemholdings a, ole_ds_item_holdings_t b
where a.ITEM_HOLDINGS_ID= b.ITEM_HOLDINGS_ID
GO

DELETE FROM uc_analitemholdings
WHERE ITEM_ID in (select ITEM_ID from uc_analitemholdingsDUP)
GO


INSERT INTO ole_ds_item_holdings_t
select * from uc_analitemholdings
GO

/* at end set sequence table for ole_ds_item_holdings_s */

update ole_ds_item_holdings_s
set id = (select max(id) from ole_ds_holdings_s)
go

/* now delete the dummy analytic items from ole_ds_item_t */

create table uc_analdeletes
(ITEM_ID int(11) NOT NULL)
go
insert uc_analdeletes
select a.ITEM_ID
FROM uc_analdummy a, uc_analreal b
where substring(a.BARCODE,2)=b.barcode
GO

DELETE ole_ds_item_stat_search_t  FROM ole_ds_item_stat_search_t 
INNER JOIN uc_analdeletes
ON ole_ds_item_stat_search_t.ITEM_ID = uc_analdeletes.ITEM_ID
go
DELETE ole_ds_itm_former_identifier_t  FROM ole_ds_itm_former_identifier_t 
INNER JOIN uc_analdeletes
ON ole_ds_itm_former_identifier_t.ITEM_ID = uc_analdeletes.ITEM_ID
go
DELETE ole_ds_item_note_t  FROM ole_ds_item_note_t 
INNER JOIN uc_analdeletes
ON ole_ds_item_note_t.ITEM_ID = uc_analdeletes.ITEM_ID
go
/* there are 63 where that dummy item is already in the ole_ds_item_holdings_t and I need to delete out to make this work  Need to look at these */
DELETE ole_ds_item_holdings_t  FROM ole_ds_item_holdings_t 
INNER JOIN uc_analdeletes
ON ole_ds_item_holdings_t.ITEM_ID = uc_analdeletes.ITEM_ID
go
/* there are 514 donor notes on dummy items we want to delete, those need to get moved to the real anal items */
DELETE ole_ds_item_donor_t  FROM ole_ds_item_donor_t 
INNER JOIN uc_analdeletes
ON ole_ds_item_donor_t.ITEM_ID = uc_analdeletes.ITEM_ID
go
/* there are 2 items in checkin count table that are going to be deleted */
DELETE ole_ds_loc_checkin_count_t  FROM ole_ds_loc_checkin_count_t 
INNER JOIN uc_analdeletes
ON ole_ds_loc_checkin_count_t.ITEM_ID = uc_analdeletes.ITEM_ID
go
DELETE ole_ds_item_t  FROM ole_ds_item_t 
INNER JOIN uc_analdeletes
ON ole_ds_item_t.ITEM_ID = uc_analdeletes.ITEM_ID
go

/* Find dummy anals that did not get changed by this */

 drop table uc_analNotLinked
go
create table uc_analNotLinked
(ITEM_ID int(11) NOT NULL)
go

insert uc_analNOtLinked
select ITEM_ID from uc_analdummy
go
create index uc_analdeletes_idx
on uc_analdeletes(ITEM_ID)
go
create index uc_analNOTLinked_idx
on uc_analNOTLinked(ITEM_ID)
go


DELETE uc_analNotLinked FROM uc_analNotLinked
INNER JOIN uc_analdeletes
ON uc_analNotLinked.ITEM_ID = uc_analdeletes.ITEM_ID
go


select a.*, b.* 
from uc_analNOtLInked a, ole_ds_item_t b
where a.ITEM_ID=b.ITEM_ID
go





