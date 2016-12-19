-- TABLES

--ga_leads_native_app
TRUNCATE TABLE staging.appwithlead;
INSERT INTO staging.appwithlead
SELECT * FROM source.ga_leads_native_app
WHERE date >= '20161212' ;

-- ga_leads_no_native_app
TRUNCATE TABLE staging.webwithlead;
INSERT INTO staging.webwithlead
SELECT * FROM source.ga_leads_no_native_app
WHERE date >= '20161212' ;

---ga_sessions_no_lead    
TRUNCATE TABLE staging.webandappnolead;
INSERT INTO staging.webandappnolead
SELECT * FROM source.ga_sessions_no_lead 
WHERE date >= '20161212' ;

-- ga_visit_platform     
TRUNCATE TABLE staging.visit_platform;
INSERT INTO staging.visit_platform
SELECT * FROM source.ga_visit_platform 
WHERE date >= '20161212' ;


--***************************************
--- 10  READ FROM WebWithLead to remove all duplicate records and update to WEBWITHLEADDEDUPED
---***************************************

--** Remove data from table from WebWithLeadDeduped
TRUNCATE TABLE staging.WebWithLeadDeduped;

INSERT INTO staging.WebWithLeadDeduped
select *
from 
(
--sitcky TransactionID with same VisitID

select [profile_id] 
      ,date
      ,[device_browser]
      ,[device_deviceCategory]
      ,[device_operatingSystem]
      ,[fullVisitorId]
      ,[geoNetwork_continent]
      ,[geoNetwork_country]
      ,[geoNetwork_subContinent]
      ,[hits_hitNumber]
      ,[hits_time]
      ,[hits_hour]
      ,[hits_minute]
      ,[hits_page_hostname]
      ,[hits_page_pagePath]
      ,[hits_product_v2ProductCategory]
      ,[hits_product_v2ProductName]
      ,[hits_transaction_transactionId]
      ,[trafficSource_campaign]
      ,[trafficSource_medium]
      ,[trafficSource_source]
      ,[trafficSource_referralPath]
      ,[visitId]
      ,[visitNumber]
      ,[visitStartTime]
      ,[totals_hits]
      ,[totals_pageviews]
      ,[totals_timeOnSite]
      ,[totals_newVisits]
      ,[totals_UniqueScreenViews]
from 
	(
		--ordering by hit number to find 1st row with actual TransactionID
		select *,
		ROW_NUMBER() OVER (PARTITION BY w.hits_transaction_transactionId ORDER BY w.hits_hitNumber) as RowID
		from staging.WebWithLead w
		where  w.hits_transaction_transactionId in
			--from those rows where the multiples transaction IDs occur in a single session
			(
			select w.hits_transaction_transactionId
			from staging.WebWithLead w

				  group by w.hits_transaction_transactionId
			having count(distinct (w.fullVisitorId+'_'+cast(w.VisitID as char(10))))=1)

	) w
where w.RowID=1

union all

--sitcky TransactionID with different VisitID
select [profile_id] 
      ,date
      ,[device_browser]
      ,[device_deviceCategory]
      ,[device_operatingSystem]
      ,[fullVisitorId]
      ,[geoNetwork_continent]
      ,[geoNetwork_country]
      ,[geoNetwork_subContinent]
      ,[hits_hitNumber]
      ,[hits_time]
      ,[hits_hour]
      ,[hits_minute]
      ,[hits_page_hostname]
      ,[hits_page_pagePath]
      ,[hits_product_v2ProductCategory]
      ,[hits_product_v2ProductName]
      ,[hits_transaction_transactionId]
      ,[trafficSource_campaign]
      ,[trafficSource_medium]
      ,[trafficSource_source]
      ,[trafficSource_referralPath]
      ,[visitId]
      ,[visitNumber]
      ,[visitStartTime]
      ,[totals_hits]
      ,[totals_pageviews]
      ,[totals_timeOnSite]
      ,[totals_newVisits]
      ,[totals_UniqueScreenViews]
from
	(

		--ordering by hit number to find 1st row with actual TransactionID
		select *,
		ROW_NUMBER() OVER (PARTITION BY w.hits_transaction_transactionId ORDER BY w.hits_hitNumber) as RowID
		from staging.WebWithLead w
		where  w.hits_transaction_transactionId in

		--from those rows where the multiples transaction IDs occur in multiple sessions (changing VisitIDs)
			(select w.hits_transaction_transactionId
			from staging.WebWithLead w
				  group by w.hits_transaction_transactionId
			having count(distinct (w.fullVisitorId+'_'+cast(w.VisitID as char(10))))>1)

	) w
where w.RowID=1

)d;


 

---*************************
--- 20:  Build GAData_delta - reads from WebWithLeadDeduped, AppWithLead, WebAndAppNoLead
---**************************


--union 3 web queries
truncate table staging.GAData_delta;

Insert into staging.GAData_delta
select *
from (

--web session with a TransactionID
select 
wl.profile_id as profile_id,
'Web lead' as WebRecordType,
cast(cast(left(wl.date,4) as char(4))+'-'+substring(cast(wl.date as char(8)),5,2)+'-'+cast(right(wl.date,2) as char(4)) as date) as "Visit date",
wl.fullVisitorId as VisitorID,
wl.visitId as VisitID,
left(wl.hits_transaction_transactionId,32) as TransactionID,
wl.device_deviceCategory as "Device category",
case 
  when wl.device_deviceCategory = 'tablet' then 'Tablet'
	when wl.device_deviceCategory = 'desktop' then 'Desktop'
	when wl.device_deviceCategory = 'mobile' then 'Smartphone'
	else 'Unknown' 
  end as Device,
wl.device_browser as Browser,
wl.device_operatingSystem as "Operating system",
'N' as "Native App",
wl.geoNetwork_continent as "User continent",
wl.geoNetwork_subContinent as "User subcontinent",
wl.geoNetwork_country as "User country",
wl.hits_page_hostname as Hostname,
wl.hits_page_pagePath as PagePath,
wl.trafficSource_source as "Traffic source",
wl.trafficSource_medium as "Traffic medium",
wl.trafficSource_campaign as "Visit campaign",
wl.hits_product_v2ProductCategory as "Web enquiry type",
wl.hits_product_v2ProductName as "Web enquiry list",
case
	when LOWER(wl.trafficSource_medium) LIKE '%feed%'
		OR LOWER(wl.trafficSource_source) IN ('nest','trov','adzuna','mitula','nuroa','newsnow','placebuzz') then 'Aggregators'
  when LOWER(wl.trafficSource_medium)  LIKE 'commercial%' THEN 'Commercial'
	when LOWER(wl.trafficSource_medium) = '(none)' then 'Direct'
	when LOWER(wl.trafficSource_medium) = 'display' then 'Display'
	when LOWER(wl.trafficSource_medium) = 'email' then 'Email'
  when LOWER(wl.trafficSource_medium) = 'network' then 'Network'
	when LOWER(wl.trafficSource_medium) = 'organic' then 'Organic Search'
	when LOWER(wl.trafficSource_medium) = 'cpc' then 'Paid Search'
  when LOWER(wl.trafficSource_medium) = 'cpc' 
    AND LOWER(wl.trafficSource_source) = 'facebook' then 'Paid Social'
	when LOWER(wl.trafficSource_medium) LIKE '%partnership%'
    OR LOWER(wl.trafficSource_medium) LIKE '%api%'
    OR LOWER(wl.trafficSource_medium) LIKE '%widget%'
    OR LOWER(wl.trafficSource_medium) LIKE '%hlink%'
		OR LOWER(wl.trafficSource_source) LIKE '%homesandproperty%'
    OR LOWER(wl.trafficSource_source) LIKE '%indy%'
    OR LOWER(wl.trafficSource_source) LIKE '%independent%' then 'Partnerships'
	when LOWER(wl.trafficSource_medium) = 'referral' then 'Referral'
	when LOWER(wl.trafficSource_source) LIKE '%twitter%'
    OR LOWER(wl.trafficSource_source) LIKE '%facebook%'
    OR LOWER(wl.trafficSource_source) LIKE '%pinterest%'
    OR LOWER(wl.trafficSource_source) = 't.co'
		OR LOWER(wl.trafficSource_medium) LIKE '%ads%'
    OR LOWER(wl.trafficSource_medium) LIKE '%page post%' then 'Social'
  when LOWER(wl.trafficSource_medium) LIKE 'trade%' then 'Trade'
	else '(Other)' 
  end as "GA channel",
case
	when LOWER(wl.trafficSource_medium) LIKE '%feed%'
		OR LOWER(wl.trafficSource_source) IN ('nest','trov','adzuna','mitula','nuroa','newsnow','placebuzz') then 'Aggregators'
	when LOWER(wl.trafficSource_medium)  LIKE 'commercial%' THEN 'Commercial'
  when LOWER(wl.trafficSource_medium) = '(none)' then 'Direct'
	when LOWER(wl.trafficSource_medium) = 'display' then 'Display'
  when LOWER(wl.trafficSource_medium) = 'network' then 'Network'
	when LOWER(wl.trafficSource_medium) = 'email' then 'CRM'
	when LOWER(wl.trafficSource_medium) = 'organic' then 'SEO'
	when LOWER(wl.trafficSource_medium) = 'cpc' then 'PPC'
	when LOWER(wl.trafficSource_medium) LIKE '%partnership%'
    OR LOWER(wl.trafficSource_medium) LIKE '%api%'
    OR LOWER(wl.trafficSource_medium) LIKE '%widget%'
    OR LOWER(wl.trafficSource_medium) LIKE '%hlink%'
		OR LOWER(wl.trafficSource_source) LIKE '%homesandproperty%'
    OR LOWER(wl.trafficSource_source) LIKE '%indy%'
    OR LOWER(wl.trafficSource_source) LIKE '%independent%' then 'Partnerships'
	when LOWER(wl.trafficSource_medium) = 'referral' then 'Referral'
	when LOWER(wl.trafficSource_source) LIKE '%twitter%'
    OR LOWER(wl.trafficSource_source) LIKE '%facebook%'
    OR LOWER(wl.trafficSource_source) LIKE '%pinterest%'
    OR LOWER(wl.trafficSource_source) = 't.co'
		OR LOWER(wl.trafficSource_medium) LIKE '%ads%'
    OR LOWER(wl.trafficSource_medium) LIKE '%page post%' then 'Social'
  when LOWER(wl.trafficSource_medium) LIKE 'trade%' then 'Trade'
	else 'Other' 
  end as "ZPG channel",
isnull(wl.hits_product_v2ProductCategory,'na')+'_'+isnull(wl.hits_product_v2ProductName,'na') as EnquiryTypeKey,
case 
  when wl.hits_page_hostname LIKE '%zoopla%' then 'Zoopla'
	when wl.hits_page_hostname LIKE '%primelocation%' then 'PrimeLocation'
	else 'Other' 
  end as Brand,
wl.totals_pageviews as TotalPageviews,
wl.totals_newVisits as NewVisits
from staging.WebWithLeadDeduped wl

union all

--native app session with a TransactionID
select 
wl.profile_id as profile_id,
'App lead' as WebRecordType,
cast(cast(left(wl.date,4) as char(4))+'-'+substring(cast(wl.date as char(8)),5,2)+'-'+cast(right(wl.date,2) as char(4)) as date) as "Visit date",
wl.fullVisitorId as VisitorID,
wl.visitId as VisitID,
left(wl.hits_transaction_transactionId,32) as TransactionID,
wl.device_deviceCategory as "Device category",
case 
  when wl.device_deviceCategory = 'tablet' then 'Tablet'
	when wl.device_deviceCategory = 'desktop' then 'Desktop'
	when wl.device_deviceCategory = 'mobile' then 'Smartphone'
	else 'Unknown' 
  end as Device,
wl.device_browser as Browser,
wl.device_operatingSystem as "Operating system",
'Y' as "Native App",
wl.geoNetwork_continent as "User continent",
wl.geoNetwork_subContinent as "User subcontinent",
wl.geoNetwork_country as "User country",
wl.hits_page_hostname as Hostname,
wl.hits_page_pagePath as PagePath,
wl.trafficSource_source as "Traffic source",
wl.trafficSource_medium as "Traffic medium",
wl.trafficSource_campaign as "Visit campaign",
wl.hits_item_productCategory as "Web enquiry type",
wl.hits_item_productName as "Web enquiry list",
case
	when LOWER(wl.trafficSource_medium) LIKE '%feed%'
		OR LOWER(wl.trafficSource_source) IN ('nest','trov','adzuna','mitula','nuroa','newsnow','placebuzz') then 'Aggregators'
  when LOWER(wl.trafficSource_medium)  LIKE 'commercial%' THEN 'Commercial'
	when LOWER(wl.trafficSource_medium) = '(none)' then 'Direct'
	when LOWER(wl.trafficSource_medium) = 'display' then 'Display'
	when LOWER(wl.trafficSource_medium) = 'email' then 'Email'
  when LOWER(wl.trafficSource_medium) = 'network' then 'Network'
	when LOWER(wl.trafficSource_medium) = 'organic' then 'Organic Search'
	when LOWER(wl.trafficSource_medium) = 'cpc' then 'Paid Search'
  when LOWER(wl.trafficSource_medium) = 'cpc' 
    AND LOWER(wl.trafficSource_source) = 'facebook' then 'Paid Social'
	when LOWER(wl.trafficSource_medium) LIKE '%partnership%'
    OR LOWER(wl.trafficSource_medium) LIKE '%api%'
    OR LOWER(wl.trafficSource_medium) LIKE '%widget%'
    OR LOWER(wl.trafficSource_medium) LIKE '%hlink%'
		OR LOWER(wl.trafficSource_source) LIKE '%homesandproperty%'
    OR LOWER(wl.trafficSource_source) LIKE '%indy%'
    OR LOWER(wl.trafficSource_source) LIKE '%independent%' then 'Partnerships'
	when LOWER(wl.trafficSource_medium) = 'referral' then 'Referral'
	when LOWER(wl.trafficSource_source) LIKE '%twitter%'
    OR LOWER(wl.trafficSource_source) LIKE '%facebook%'
    OR LOWER(wl.trafficSource_source) LIKE '%pinterest%'
    OR LOWER(wl.trafficSource_source) = 't.co'
		OR LOWER(wl.trafficSource_medium) LIKE '%ads%'
    OR LOWER(wl.trafficSource_medium) LIKE '%page post%' then 'Social'
  when LOWER(wl.trafficSource_medium) LIKE 'trade%' then 'Trade'
	else '(Other)' 
  end as "GA channel",
case
	when LOWER(wl.trafficSource_medium) LIKE '%feed%'
		OR LOWER(wl.trafficSource_source) IN ('nest','trov','adzuna','mitula','nuroa','newsnow','placebuzz') then 'Aggregators'
	when LOWER(wl.trafficSource_medium)  LIKE 'commercial%' THEN 'Commercial'
  when LOWER(wl.trafficSource_medium) = '(none)' then 'Direct'
	when LOWER(wl.trafficSource_medium) = 'display' then 'Display'
  when LOWER(wl.trafficSource_medium) = 'network' then 'Network'
	when LOWER(wl.trafficSource_medium) = 'email' then 'CRM'
	when LOWER(wl.trafficSource_medium) = 'organic' then 'SEO'
	when LOWER(wl.trafficSource_medium) = 'cpc' then 'PPC'
	when LOWER(wl.trafficSource_medium) LIKE '%partnership%'
    OR LOWER(wl.trafficSource_medium) LIKE '%api%'
    OR LOWER(wl.trafficSource_medium) LIKE '%widget%'
    OR LOWER(wl.trafficSource_medium) LIKE '%hlink%'
		OR LOWER(wl.trafficSource_source) LIKE '%homesandproperty%'
    OR LOWER(wl.trafficSource_source) LIKE '%indy%'
    OR LOWER(wl.trafficSource_source) LIKE '%independent%' then 'Partnerships'
	when LOWER(wl.trafficSource_medium) = 'referral' then 'Referral'
	when LOWER(wl.trafficSource_source) LIKE '%twitter%'
    OR LOWER(wl.trafficSource_source) LIKE '%facebook%'
    OR LOWER(wl.trafficSource_source) LIKE '%pinterest%'
    OR LOWER(wl.trafficSource_source) = 't.co'
		OR LOWER(wl.trafficSource_medium) LIKE '%ads%'
    OR LOWER(wl.trafficSource_medium) LIKE '%page post%' then 'Social'
  when LOWER(wl.trafficSource_medium) LIKE 'trade%' then 'Trade'
	else 'Other' 
  end as "ZPG channel",
isnull(wl.hits_item_productCategory,'na')+'_'+isnull(wl.hits_item_productName,'na') as EnquiryTypeKey,
case 
  when wl.hits_page_hostname LIKE '%zoopla%' then 'Zoopla'
	when wl.hits_page_hostname LIKE '%primelocation%' then 'PrimeLocation'
	else 'Other' 
  end as Brand,
wl.totals_pageviews as TotalPageviews,
wl.totals_newVisits as NewVisits
from staging.AppWithLead wl

union all

--web session with no TransactionID
select 
wl.profile_id as profile_id,
'Session' as WebRecordType,
cast(cast(left(wl.date,4) as char(4))+'-'+substring(cast(wl.date as char(8)),5,2)+'-'+cast(right(wl.date,2) as char(4)) as date) as "Visit date",
wl.fullVisitorId as VisitorID,
wl.visitId as VisitID,
NULL as TransactionID,
wl.device_deviceCategory as "Device category",
case 
  when wl.device_deviceCategory = 'tablet' then 'Tablet'
	when wl.device_deviceCategory = 'desktop' then 'Desktop'
	when wl.device_deviceCategory = 'mobile' then 'Smartphone'
	else 'Unknown' 
  end as Device,
wl.device_browser as Browser,
wl.device_operatingSystem as "Operating system",
case when wl.hits_appInfo_appName is null then 'N' else 'Y' end as "Native App",
wl.geoNetwork_continent as "User continent",
wl.geoNetwork_subContinent as "User subcontinent",
wl.geoNetwork_country as "User country",
wl.hits_page_hostname as Hostname,
NULL as PagePath,
wl.trafficSource_source as "Traffic source",
wl.trafficSource_medium as "Traffic medium",
wl.trafficSource_campaign as "Visit campaign",
NULL as "Web enquiry type",
NULL as "Web enquiry list",
case
	when LOWER(wl.trafficSource_medium) LIKE '%feed%'
		OR LOWER(wl.trafficSource_source) IN ('nest','trov','adzuna','mitula','nuroa','newsnow','placebuzz') then 'Aggregators'
  when LOWER(wl.trafficSource_medium)  LIKE 'commercial%' THEN 'Commercial'
	when LOWER(wl.trafficSource_medium) = '(none)' then 'Direct'
	when LOWER(wl.trafficSource_medium) = 'display' then 'Display'
	when LOWER(wl.trafficSource_medium) = 'email' then 'Email'
  when LOWER(wl.trafficSource_medium) = 'network' then 'Network'
	when LOWER(wl.trafficSource_medium) = 'organic' then 'Organic Search'
	when LOWER(wl.trafficSource_medium) = 'cpc' then 'Paid Search'
  when LOWER(wl.trafficSource_medium) = 'cpc' 
    AND LOWER(wl.trafficSource_source) = 'facebook' then 'Paid Social'
	when LOWER(wl.trafficSource_medium) LIKE '%partnership%'
    OR LOWER(wl.trafficSource_medium) LIKE '%api%'
    OR LOWER(wl.trafficSource_medium) LIKE '%widget%'
    OR LOWER(wl.trafficSource_medium) LIKE '%hlink%'
		OR LOWER(wl.trafficSource_source) LIKE '%homesandproperty%'
    OR LOWER(wl.trafficSource_source) LIKE '%indy%'
    OR LOWER(wl.trafficSource_source) LIKE '%independent%' then 'Partnerships'
	when LOWER(wl.trafficSource_medium) = 'referral' then 'Referral'
	when LOWER(wl.trafficSource_source) LIKE '%twitter%'
    OR LOWER(wl.trafficSource_source) LIKE '%facebook%'
    OR LOWER(wl.trafficSource_source) LIKE '%pinterest%'
    OR LOWER(wl.trafficSource_source) = 't.co'
		OR LOWER(wl.trafficSource_medium) LIKE '%ads%'
    OR LOWER(wl.trafficSource_medium) LIKE '%page post%' then 'Social'
  when LOWER(wl.trafficSource_medium) LIKE 'trade%' then 'Trade'
	else '(Other)' 
  end as "GA channel",
case
	when LOWER(wl.trafficSource_medium) LIKE '%feed%'
		OR LOWER(wl.trafficSource_source) IN ('nest','trov','adzuna','mitula','nuroa','newsnow','placebuzz') then 'Aggregators'
	when LOWER(wl.trafficSource_medium)  LIKE 'commercial%' THEN 'Commercial'
  when LOWER(wl.trafficSource_medium) = '(none)' then 'Direct'
	when LOWER(wl.trafficSource_medium) = 'display' then 'Display'
  when LOWER(wl.trafficSource_medium) = 'network' then 'Network'
	when LOWER(wl.trafficSource_medium) = 'email' then 'CRM'
	when LOWER(wl.trafficSource_medium) = 'organic' then 'SEO'
	when LOWER(wl.trafficSource_medium) = 'cpc' then 'PPC'
	when LOWER(wl.trafficSource_medium) LIKE '%partnership%'
    OR LOWER(wl.trafficSource_medium) LIKE '%api%'
    OR LOWER(wl.trafficSource_medium) LIKE '%widget%'
    OR LOWER(wl.trafficSource_medium) LIKE '%hlink%'
		OR LOWER(wl.trafficSource_source) LIKE '%homesandproperty%'
    OR LOWER(wl.trafficSource_source) LIKE '%indy%'
    OR LOWER(wl.trafficSource_source) LIKE '%independent%' then 'Partnerships'
	when LOWER(wl.trafficSource_medium) = 'referral' then 'Referral'
	when LOWER(wl.trafficSource_source) LIKE '%twitter%'
    OR LOWER(wl.trafficSource_source) LIKE '%facebook%'
    OR LOWER(wl.trafficSource_source) LIKE '%pinterest%'
    OR LOWER(wl.trafficSource_source) = 't.co'
		OR LOWER(wl.trafficSource_medium) LIKE '%ads%'
    OR LOWER(wl.trafficSource_medium) LIKE '%page post%' then 'Social'
  when LOWER(wl.trafficSource_medium) LIKE 'trade%' then 'Trade'
	else 'Other' 
  end as "ZPG channel",
NULL as EnquiryTypeKey,
case 
  when wl.hits_page_hostname LIKE '%zoopla%' then 'Zoopla'
	when wl.hits_page_hostname LIKE '%primelocation%' then 'PrimeLocation'
	else 'Other' 
  end as Brand,
wl.totals_pageviews as TotalPageviews,
wl.totals_newVisits as NewVisits
from staging.WebAndAppNoLead wl

) w;


---*************************************************
--- 30:  Create LeadsLink_delta table - ...webwithleaddeduped, AppWithLead , agent_leads_unique_identifiers
 ---*************************************************


--prepare link table
--provides table with TransactionID and corresponding lead_id via unique_lead_identifier
--truncate staging.LeadsLink_delta;

TRUNCATE TABLE staging.LeadsLink_delta;

Insert into staging.LeadsLink_delta
select *
from (

--TransactionIDs with 32 characters (relating to unqie identifier)
select wl.SessionDate,
wl.VisitorID,
wl.VisitID,
wl.TransactionID,
i.lead_id,
i.lead_type
from (

  --web with TransactionID
	select cast(cast(left(wl.date,4) as char(4))+'-'+substring(cast(wl.date as char(8)),5,2)+'-'+cast(right(wl.date,2) as char(4)) as date) as SessionDate,
	wl.fullVisitorId as VisitorID,
	wl.visitId as VisitID,
	left(wl.hits_transaction_transactionId,32) as TransactionID
	--already includes delta logic
  from staging.webwithleaddeduped wl  
  where len(wl.hits_transaction_transactionId)>=32
	group by cast(cast(left(wl.date,4) as char(4))+'-'+substring(cast(wl.date as char(8)),5,2)+'-'+cast(right(wl.date,2) as char(4)) as date),
	wl.fullVisitorId,
	wl.visitId,
	left(wl.hits_transaction_transactionId,32)

	union all

  --native app with TransactionID
	select cast(cast(left(wl.date,4) as char(4))+'-'+substring(cast(wl.date as char(8)),5,2)+'-'+cast(right(wl.date,2) as char(4)) as date) as SessionDate,
	wl.fullVisitorId as VisitorID,
	wl.visitId as VisitID,
	left(wl.hits_transaction_transactionId,32) as TransactionID
	from staging.AppWithLead wl
	where len(wl.hits_transaction_transactionId)>=32
	group by cast(cast(left(wl.date,4) as char(4))+'-'+substring(cast(wl.date as char(8)),5,2)+'-'+cast(right(wl.date,2) as char(4)) as date),
	wl.fullVisitorId,
	wl.visitId,
	left(wl.hits_transaction_transactionId,32)
												) wl

inner join source.agent_leads_unique_identifiers i
	on wl.TransactionID=i.unique_lead_identifier
group by wl.SessionDate,
wl.VisitorID,
wl.VisitID,
wl.TransactionID,
i.lead_id,
i.lead_type

union all

--TransactionIDs with 8 characters (relating to old lead_id)
select wl.SessionDate,
wl.VisitorID,
wl.VisitID,
wl.TransactionID,
9999999 as lead_id,
'Unknown' as lead_type
from (

  --web with TransactionID
	select cast(cast(left(wl.date,4) as char(4))+'-'+substring(cast(wl.date as char(8)),5,2)+'-'+cast(right(wl.date,2) as char(4)) as date) as SessionDate,
	wl.fullVisitorId as VisitorID,
	wl.visitId as VisitID,
	wl.hits_transaction_transactionId as TransactionID
	--already includes delta logic
  from staging.webwithleaddeduped wl
	where len(wl.hits_transaction_transactionId)<32
	group by cast(cast(left(wl.date,4) as char(4))+'-'+substring(cast(wl.date as char(8)),5,2)+'-'+cast(right(wl.date,2) as char(4)) as date),
	wl.fullVisitorId,
	wl.visitId,
	wl.hits_transaction_transactionId

	union all

  --native app with TransactionID
	select cast(cast(left(wl.date,4) as char(4))+'-'+substring(cast(wl.date as char(8)),5,2)+'-'+cast(right(wl.date,2) as char(4)) as date) as SessionDate,
	wl.fullVisitorId as VisitorID,
	wl.visitId as VisitID,
	wl.hits_transaction_transactionId as TransactionID
	from staging.AppWithLead wl	where len(wl.hits_transaction_transactionId)<32
	group by cast(cast(left(wl.date,4) as char(4))+'-'+substring(cast(wl.date as char(8)),5,2)+'-'+cast(right(wl.date,2) as char(4)) as date),
	wl.fullVisitorId,
	wl.visitId,
	wl.hits_transaction_transactionId
												) wl

--inner join source.agent_leads_unique_identifiers i  --dropped as not relevant for older lead IDs
--	on wl.TransactionID=i.lead_id
group by 1,2,3,4,5,6
				)d;

truncate staging.ZPGLeads_delta;

Insert into staging.ZPGLeads_delta
select *
from (

--Individual listings data
select 'Listing' as LeadRecordType,
sl.lead_id as DistinctLeadID,
cast(sl.creation_date as date) as LeadCreationDate,
'Email' as Lead,
sl.listing_type as type_of_lead,
case 
  when sl.listing_type in ('for_sale','sale_under_offer','sold') then 'For Sale'
	when sl.listing_type in ('to_rent','for_rent','rent_under_offer','rented') then 'For Rent'
	when sl.listing_type = 'askanagent' then 'Appraisal'
	when sl.listing_type = 'findanagent' then 'Find An Agent'
	when sl.listing_type = 'email_all' then 'Email All'
	else 'n/a' 
  end as "Lead type",
sl.type_of_enquiry as "Enquiry type",
case when sl.sent='Y' then 'Yes' else 'No' end as "Lead sent",
sl.branch_id as BranchID,
cast(sl.lead_id as varchar(8))+'_'+cast(sl.branch_id as varchar(5)) as LeadID,
cast(sl.sent_date as date) as "Lead date",
case 
  when sl.listing_country_code = 'gb' then 'Domestic'
	when len(sl.listing_country_code) = 2 and sl.listing_country_code <> 'gb' then 'Overseas'
	else 'n/a' 
  end as "Listing location",
isnull(UPPER(sl.listing_country_code),'n/a') as "Listing country"
from source.source_listing_agent_leads_nopii sl
where (sl.sent='Y' OR sl.sent='N')
and (sl.sent_date between  '12/12/2016' and '12/19/2016')

union all

--"Email all" data
select 'Search' as LeadRecordType,
al.lead_id as DistinctLeadID,
cast(al.creation_date as date) as LeadCreationDate,
'Email' as Lead,
al.type_of_lead,
case 
  when al.type_of_lead in ('for_sale','sale_under_offer','sold') then 'For Sale'
	when al.type_of_lead in ('to_rent','for_rent','rent_under_offer','rented') then 'For Rent'
	when al.type_of_lead = 'askanagent' then 'Appraisal'
	when al.type_of_lead = 'findanagent' then 'Find An Agent'
	when al.type_of_lead = 'email_all' then 'Email All'
	else 'n/a' 
  end as "Lead type",
al.type_of_enquiry as "Enquiry type",
case when alsent.sent='Y' then 'Yes' else 'No' end as "Lead sent",
alsent.branch_id as BranchID,
cast(alsent.lead_id as varchar(8))+'_'+cast(alsent.branch_id as varchar(5)) as LeadID,
cast(alsent.sent_date as date) as "Lead date",
case 
  when al.country_code = 'gb' then 'Domestic'
	when len(al.country_code) = 2 and al.country_code <> 'gb' then 'Overseas'
	else 'n/a' 
  end as "Listing location",
isnull(UPPER(al.country_code),'n/a') as "Listing country"
from source.agent_leads_nopii al
inner join source.agent_leads_sent alsent
	on al.lead_id=alsent.lead_id
--lead type not required
where al.type_of_lead<> 'temptme'
and (alsent.sent_date between  '12/12/2016' and '12/19/2016')
union all

--Phone leads
select 'Phone' as LeadRecordType,
--adding minus sign to ensure no overlap with lead_id range
-pl.id as DistinctLeadID,
cast(pl.creation_date as date) as LeadCreationDate,
'Phone' as Lead,
'phone' as type_of_lead,
'Phone' as "Lead type",
'n/a' as "Enquiry type",
'Yes' as "Lead sent",
pl.branch_id as BranchID,
cast(pl.id as varchar(8))+'_'+cast(pl.branch_id as varchar(5)) as LeadID,
cast(pl.call_start as date) as "Lead date",
'n/a' as "Listing location",
'n/a' as "Listing country"
from source.agent_phone_leads_nopii pl
Where pl.call_start between '12/12/2016' and '12/19/2016'
) d;


Truncate staging.JoinedDataFinalStaging_delta;

Insert into staging.JoinedDataFinalStaging_delta
select

		--unique row identifier created by concatenating all fields used to guarantee uniqueness
		isnull(cast(g."Visit date" as char(10)),'na')+isnull(cast(z."Lead date" as char(10)),'na')+isnull(cast(z.LeadCreationDate as char(10)),'na')+isnull(g.Brand,'na')+isnull(cast(g.Hostname as varchar(128)),'na')
		+isnull(g.Device,'na')+isnull(g."Device category",'na')+isnull(g."Operating system",'na')+isnull(g.Browser,'na')+isnull(g."Native App",'na')
		+isnull(CASE
		  WHEN g.profile_id = 61296626 AND p.platform IS NOT NULL THEN p.platform
		  WHEN g.profile_id = 61296626 AND p.platform IS NULL AND g.hostname LIKE 'www.%' THEN 'Desktop'
		  WHEN g.profile_id = 61296626 AND p.platform IS NULL AND g.hostname LIKE 'm.%' THEN 'Mobile'
		  ELSE 'App'
		  END, 'na')
		+isnull(g."User country",'na')
		+isnull(g.WebRecordType,'na')+isnull(g."GA channel",'na')+isnull(g."ZPG channel",'na')+isnull(g."Traffic source",'na')+isnull(g."Traffic medium",'na')
		+isnull(cast(g.NewVisits as char(1)),'na')+isnull(g."web enquiry list" ,'na')+checksum(isnull(cast(g.PagePath as varchar(2048)),'na'))+isnull(g.EnquiryTypeKey,'na')+isnull(z."Lead type",'na')
		+isnull(cast(z."Enquiry type" as varchar(128)),'na')+isnull(z."Listing location",'na')+isnull(cast(z."Listing country" as varchar(2)),'na')
		+(case when z.LeadRecordType is null then null	when z.type_of_lead='askanagent' then 'Appraisal'	when z.type_of_lead='phone' then 'Phone'	else 'Email' end) as UniqueRowID,

		--datetime dim
		g."Visit date",
		z.LeadCreationDate as "Lead creation date",
		z."Lead date",

		--Brand dim
		isnull(g.Brand,'na')+'_'+isnull(g.Hostname,'na') as DimBrandKey,
		g.Brand,
		g.Hostname,

		----Device dim
		isnull(g.Device,'Unknown') as Device,

		----System dim
		isnull(g."Device category",'na')+'_'+isnull(g."Operating system",'na')+'_'+isnull(g.Browser,'na')+'_'+isnull(g."Native App",'na')+'_'+isnull(CASE
		  WHEN g.profile_id = 61296626 AND p.platform IS NOT NULL THEN p.platform
		  WHEN g.profile_id = 61296626 AND p.platform IS NULL AND g.hostname LIKE 'www.%' THEN 'Desktop'
		  WHEN g.profile_id = 61296626 AND p.platform IS NULL AND g.hostname LIKE 'm.%' THEN 'Mobile'
		  ELSE 'App'
		  END ,'na') as DimSystemKey,
		isnull(g."Device category",'Unknown') as "Device category",
		g."Operating system",
		g.Browser,
		g."Native App",
		CASE
		  WHEN g.profile_id = 61296626 AND p.platform IS NOT NULL THEN p.platform
		  WHEN g.profile_id = 61296626 AND p.platform IS NULL AND g.hostname LIKE 'www.%' THEN 'Desktop'
		  WHEN g.profile_id = 61296626 AND p.platform IS NULL AND g.hostname LIKE 'm.%' THEN 'Mobile'
		  ELSE 'App'
		  END AS Platform,

		--Location dim
		--no need to add all fields to business key in this instance
		isnull(g."User country",'na') as DimUserLocationKey,
		g."User continent",
		g."User subcontinent",
		g."User country",

		--Session dim
		isnull(g.WebRecordType,'na')+'_'+isnull(g."GA channel",'na')+'_'+isnull(g."ZPG channel",'na')+'_'+isnull(g."Traffic source",'na')+'_'+
		isnull(g."Traffic medium",'na')+'_'+isnull(cast(g.NewVisits as char(1)),'na')+'_'+isnull(g."web enquiry list",'na') as DimSessionKey,
		g.WebRecordType,
		g."GA channel",
		g."ZPG channel",
		g."Traffic source",
		g."Traffic medium",
		case when g.NewVisits=1 then 'True'
			else 'False' end as "New visitor",
		case when g.NewVisits=1 then 'New'
			else 'Returning' end as "Visitor type",

		g."Web enquiry list" as Product,

		case 
		  when (LOWER(g."Web enquiry list") IN ('cl_contact','cl_results','fa_results') AND LOWER(g."Web enquiry type") = 'commercial let')
			OR (LOWER(g."Web enquiry list") IN ('cs_contact','cs_results','fa_results') AND LOWER(g."Web enquiry type") = 'commercial sale') then 'Commercial'
		  when (LOWER(g."Web enquiry list") IN ('nh_brochure','nh_contact','nh_results') AND LOWER(g."Web enquiry type") = 'for sale') then 'Developer'
		  when (LOWER(g."Web enquiry list") IN ('os_contact','os_results') AND LOWER(g."Web enquiry type") = 'for sale') then 'Overseas'
		  when (LOWER(g."Web enquiry list") IN ('tr_contact','tr_results','fa_results','fa_contact') AND LOWER(g."Web enquiry type") = 'to rent')
			OR (LOWER(g."Web enquiry list") IN ('fs_contact','fs_results','fa_results','fa_contact') AND LOWER(g."Web enquiry type") = 'for sale')
			OR (LOWER(g."Web enquiry list") IN ('aaa_contact','fa_results','fa_contact') AND LOWER(g."Web enquiry type") = 'lessor')
			OR (LOWER(g."Web enquiry list") IN ('aaa_contact','fa_results','fa_contact') AND LOWER(g."Web enquiry type") = 'vendor')
			OR (LOWER(g."Web enquiry list") IN ('aaa_contact','fa_results','fa_contact','fa_brochure') AND LOWER(g."Web enquiry type") = '(not set)') then 'UK Residential'
		  else 'Unknown' 
		  end as Market,

		--Page path dim
		--matching business key to table Transactionpagepath
		checksum(isnull(g.PagePath,'na')) as DimPagePathKey,

		--Enquiry type
		isnull(g.EnquiryTypeKey,'na') as EnquiryTypeKey,
		el.ActivityType,
		el.InfoType,
		el.MarketType, 
		/* MarketType comes from a derived table created by Giles, enquirytypelookup. This differs from market when it shouldn't do. The derived table contains incorrect logic */		--Lead dim
		isnull(z."Lead type",'na')+'_'+isnull(z."Enquiry type",'na')+'_'+isnull(z."Lead sent",'na') as DimLeadKey,

		  --now in LeadForecastDim
		  z.Lead,

		z."Lead type",
		z."Enquiry type" as "Enquiry type",
		z."Lead sent",

		--Listing location dim
		isnull(z."Listing location",'na')+'_'+isnull(z."Listing country",'na') as DimListingLocationKey,
		z."Listing location",
		z."Listing country",

		--adding lead forecast level key
		-- to match forecast level of grain
		(case when z.LeadRecordType is null then null
			when z.type_of_lead='askanagent' then 'Appraisal'
			when z.type_of_lead='phone' then 'Phone'	
			else 'Email' end) as LeadForecastKey,
  
		 --adding Lead category
		 --accounting for web sessions that have no transactions
		 case when z.LeadRecordType is null then null

		  when z.type_of_lead='askanagent' then 'Appraisal'
			else 'Applicant' end as "Lead category",

		--FACTs
		--definition of a session
		g.VisitorID+'_'+cast(g.VisitID as char(10)) as SessionID,

		g.TransactionID,
		g.TotalPageviews,
		z.BranchID,
		z.LeadID,
		cast(z.DistinctLeadID as char(14)) as DistinctLeadID,
    CASE 
      WHEN browser like 'Chrome%' THEN 'Chrome'
      WHEN browser like '%chrome%' THEN 'Chrome'
      WHEN browser like 'Safari%' THEN 'Safari'
      WHEN browser like 'Internet %' THEN 'Internet Explorer'
      WHEN browser like 'internet explorer' THEN 'Internet Explorer'
      WHEN browser like 'IE' THEN 'Internet Explorer'
      WHEN browser like 'IE%' THEN 'Internet Explorer'
      WHEN browser like 'MSIE' THEN 'Internet Explorer'
      WHEN browser like '%MSIE%' THEN 'Internet Explorer'
      WHEN browser like 'Kindle%' THEN 'Kindle Fire'
      WHEN browser in ('Firefox', 'Mozilla', 'Mozilla Compatible Agent') THEN 'Firefox'
      WHEN browser LIKE '%Mozilla%' THEN 'Firefox'
      WHEN browser LIKE '%mozilla%' THEN 'Firefox'
      WHEN browser LIKE 'Firefox%' THEN 'Firefox'
      WHEN browser like 'Edge' THEN 'Edge'
      WHEN browser like 'Android%' THEN 'Android'
      WHEN browser like '%Android%' THEN 'Android'
      WHEN browser like 'Opera%' THEN 'Opera'
      WHEN browser like '%Opera%' THEN 'Opera'
      When browser like 'BlackBerry%' THEN 'BlackBerry'
      WHEN browser in ('Nintendo Browser', 'Playstation Vita Browser', 'Playstation 3', 'Playstation 4') THEN 'Gaming Console'
      ELSE 'Other' 
      END AS "Browser Group"

from staging.GAData_delta g
	left join staging.visit_platform p
	  on g."visit date"=cast(cast(left(p.date,4) as char(4))+'-'+substring(cast(p.date as char(8)),5,2)+'-'+cast(right(p.date,2) as char(4)) as date)
	  and g.visitorid=p.fullvisitorid
	  and g.visitid=p.visitid
	left join staging.EnquiryTypeLookup el
		on g.EnquiryTypeKey=el.EnquiryTypeKey
	left join staging.LeadsLink_delta l
		on g.TransactionID=l.TransactionID 
		--not necessarily required
	  and g."Visit date"=l.SessionDate
		and g.VisitorID=l.VisitorID
		and g.VisitID=l.VisitID
	full join staging.ZPGLeads_delta z
		on l.lead_id=z.DistinctLeadID
	--on l.lead_type=z.leadrecordtype --this will need fixing up
  
    ;



---Truncate table BirstAggregatedFeed;

Insert into staging.fullfeed
select *
from (
select
checksum(g.UniqueRowID) as RowChecksum,
g."Visit date",
g."Lead date",
g."Lead creation date",
g.DimBrandKey,
g.Brand,
g.Hostname,
g.Device,
g.DimSystemKey,
g."Device category",
g."Operating system",
g.Browser,
g."Native App",
g.Platform,
g.DimUserLocationKey,
g."User continent",
g."User subcontinent",
g."User country",
g.DimSessionKey,
g.WebRecordType,
g."GA channel",
g."ZPG channel",
g."Traffic source",
g."Traffic medium",
g."New visitor",
g."Visitor type",
g.Product,
g.Market,
g.DimPagePathKey,
g.EnquiryTypeKey,
g.ActivityType,
g.InfoType,
g.MarketType,
g.DimLeadKey,
g.Lead,
g."Lead type",
g."Enquiry type",
g."Lead sent",
g.DimListingLocationKey,
g."Listing location",
g."Listing country",
g."LeadForecastKey",
g."Lead category",

--FACTs
--create the measures
count(distinct g.SessionID) as NoOfVisits,
count(distinct g.TransactionID) as NoOfTransactions,
count(distinct g.LeadID) as NoOfLeads,
count(distinct g.DistinctLeadID) as NoOfDistinctLeads,
sum(g.TotalPageviews) as NoOfPageviews,

g."Browser Group"

from staging.JoinedDataFinalStaging_delta g

--group by all the non-measure attributes to guarantee no loss of information
group by checksum(g.UniqueRowID),
g."Visit date",
g."Lead date",
g."Lead creation date",
g.DimBrandKey,
g.Brand,
g.Hostname,
g.Device,
g.DimSystemKey,
g."Device category",
g."Operating system",
g.Browser,
g."Native App",
g.Platform,
g.DimUserLocationKey,
g."User continent",
g."User subcontinent",
g."User country",
g.DimSessionKey,
g.WebRecordType,
g."GA channel",
g."ZPG channel",
g."Traffic source",
g."Traffic medium",
g."New visitor",
g."Visitor type",
g.Product,
g.Market,
g.DimPagePathKey,
g.EnquiryTypeKey,
g.ActivityType,
g.InfoType,
g.MarketType,
g.DimLeadKey,
g.Lead,
g."Lead type",
g."Enquiry type",
g."Lead sent",
g.DimListingLocationKey,
g."Listing location",
g."Listing country",
g."LeadForecastKey",
g."Lead category",
g."Browser Group"
                    ) d;