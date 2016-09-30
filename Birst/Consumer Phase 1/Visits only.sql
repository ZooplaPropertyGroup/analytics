/* Final staging */
SELECT
	allvisits."Visit Date",
	allvisits.DimBrandKey,
	allvisits.Hostname,
	allvisits.Brand,
	allvisits.DimSystemKey,
	allvisits."Device Category",
	allvisits.Device,
	allvisits."Operating System",
	allvisits.Browser,
	allvisits."Browser Group",
	allvisits."Native App",
	CASE 
		WHEN allvisits.Platform IN ('d','desk','deskto','desktop') THEN 'Desktop'
		WHEN allvisits.Platform IN ('m','mo','mob','mobi','mobil','mobile') THEN 'Mobile'
		WHEN allvisits.Platform = 'app' THEN 'App'
		WHEN allvisits.Platform = 'native-app' THEN 'Native App'
		WHEN allvisits.Platform = ' ' THEN 'Unknown'
		ELSE allvisits.Platform
		END AS Platform,
	allvisits.DimUserLocationKey,
	allvisits."User Continent",
	allvisits."User Subcontinent",
	allvisits."User Country",
	allvisits.DimSessionKey,
	allvisits.WebRecordType,
	allvisits."GA Channel",
	allvisits."ZPG Channel",
	allvisits."Traffic Source",
	allvisits."Traffic Medium",
	allvisits."New Visitor",
	allvisits."Visitor Type",
	allvisits.Product,
	allvisits.Market,
	allvisits.DimPagePathKey,
	allvisits.SessionID,
	allvisits.TransactionID,
	allvisits.TotalPageviews
FROM
(
	/* Join to platform and transformations */
	SELECT
		v."Visit Date",
		ISNULL(v.Brand,'na') + '_' + ISNULL(v.Hostname,'na') AS DimBrandKey,
		ISNULL(v.Hostname,'Unknown') AS Hostname,
		ISNULL(v.Brand,'Unknown') AS Brand,
		ISNULL(v."Device Category",'na') + '_' + ISNULL(v."Operating System",'na') + '_' + ISNULL(v.Browser,'na') + '_' + ISNULL(v."Native App",'na') + '_' + 
			ISNULL(CASE
			WHEN v.profile_id = 61296626 AND p.customdimensions_value IS NOT NULL THEN p.customdimensions_value
			WHEN v.profile_id = 61296626 AND p.customdimensions_value IS NULL AND v.hostname LIKE 'www.%' THEN 'Desktop'
			WHEN v.profile_id = 61296626 AND p.customdimensions_value IS NULL AND v.hostname LIKE 'm.%' THEN 'Mobile'
			ELSE 'App'
			END,'na') AS DimSystemKey,
		CASE 
			WHEN v."Device Category" = 'tablet' THEN 'Tablet'
			WHEN v."Device Category" = 'desktop' THEN 'Desktop'
			WHEN v."Device Category" = 'mobile' THEN 'Mobile'
			ELSE 'Unknown' 
			END AS "Device Category",
		CASE 
			WHEN v."Device Category" = 'tablet' THEN 'Tablet'
			WHEN v."Device Category" = 'desktop' THEN 'Desktop'
			WHEN v."Device Category" = 'mobile' THEN 'Smartphone'
			ELSE 'Unknown' 
			END AS Device,
		ISNULL(v."Operating System",'Unknown') AS "Operating System",
		ISNULL(v.Browser,'Unknown') AS Browser,
		CASE 
			WHEN v.Browser LIKE 'Chrome%' THEN 'Chrome'
			WHEN v.Browser LIKE '%chrome%' THEN 'Chrome'
			WHEN v.Browser LIKE 'Safari%' THEN 'Safari'
			WHEN v.Browser LIKE 'Internet %' THEN 'Internet Explorer'
			WHEN v.Browser LIKE 'internet explorer' THEN 'Internet Explorer'
			WHEN v.Browser LIKE 'IE' THEN 'Internet Explorer'
			WHEN v.Browser LIKE 'IE%' THEN 'Internet Explorer'
			WHEN v.Browser LIKE 'MSIE' THEN 'Internet Explorer'
			WHEN v.Browser LIKE '%MSIE%' THEN 'Internet Explorer'
			WHEN v.Browser LIKE 'Kindle%' THEN 'Kindle Fire'
			WHEN v.Browser IN ('Firefox', 'Mozilla', 'Mozilla Compatible Agent') THEN 'Firefox'
			WHEN v.Browser LIKE '%Mozilla%' THEN 'Firefox'
			WHEN v.Browser LIKE '%mozilla%' THEN 'Firefox'
			WHEN v.Browser LIKE 'Firefox%' THEN 'Firefox'
			WHEN v.Browser LIKE 'Edge' THEN 'Edge'
			WHEN v.Browser LIKE 'Android%' THEN 'Android'
			WHEN v.Browser LIKE '%Android%' THEN 'Android'
			WHEN v.Browser LIKE 'Opera%' THEN 'Opera'
			WHEN v.Browser LIKE '%Opera%' THEN 'Opera'
			WHEN v.Browser LIKE 'BlackBerry%' THEN 'BlackBerry'
			WHEN v.Browser IN ('Nintendo Browser', 'Playstation Vita Browser', 'Playstation 3', 'Playstation 4') THEN 'Gaming Console'
			ELSE 'Other' 
			END AS "Browser Group",
		v."Native App",
		CASE
			WHEN v.profile_id = 61296626 AND p.customdimensions_value IS NOT NULL THEN p.customdimensions_value
			WHEN v.profile_id = 61296626 AND p.customdimensions_value IS NULL AND v.hostname LIKE 'www.%' THEN 'Desktop'
			WHEN v.profile_id = 61296626 AND p.customdimensions_value IS NULL AND v.hostname LIKE 'm.%' THEN 'Mobile'
			ELSE 'App'
			END AS Platform,
		ISNULL(v."User Country",'na') AS DimUserLocationKey,
		ISNULL(v."User Continent",'Unknown') AS "User Continent",
		ISNULL(v."User Subcontinent",'Unknown') AS "User Subcontinent",
		ISNULL(v."User Country",'Unknown') AS "User Country",
		ISNULL(v.WebRecordType,'na') + '_' + ISNULL(v."GA Channel",'na') + '_' + ISNULL(v."ZPG Channel",'na') + '_' + ISNULL(v."Traffic Source",'na') + '_' +
			ISNULL(v."Traffic Medium",'na') + '_' + ISNULL(CAST(v.NewVisits AS CHAR(1)),'na') + '_' + ISNULL(v."Web Enquiry List",'na') AS DimSessionKey,
		v.WebRecordType,
		ISNULL(v."GA Channel",'Unknown') AS "GA Channel",
		ISNULL(v."ZPG Channel",'Unknown') AS "ZPG Channel",
		ISNULL(v."Traffic Source",'Unknown') AS "Traffic Source",
		ISNULL(v."Traffic Medium",'Unknown') AS "Traffic Medium",
		v."New Visitor",
		v."Visitor Type",
		ISNULL(v."Web Enquiry List",'Unknown') AS Product,
		CASE 
			WHEN (LOWER(v."Web Enquiry List") IN ('cl_contact','cl_results','fa_results') AND LOWER(v."Web enquiry type") = 'commercial let')
				OR (LOWER(v."Web Enquiry List") IN ('cs_contact','cs_results','fa_results') AND LOWER(v."Web enquiry type") = 'commercial sale') THEN 'Commercial'
			WHEN (LOWER(v."Web Enquiry List") IN ('nh_brochure','nh_contact','nh_results') AND LOWER(v."Web enquiry type") = 'for sale') THEN 'Developer'
			WHEN (LOWER(v."Web Enquiry List") IN ('os_contact','os_results') AND LOWER(v."Web enquiry type") = 'for sale') THEN 'Overseas'
			WHEN (LOWER(v."Web Enquiry List") IN ('tr_contact','tr_results','fa_results','fa_contact') AND LOWER(v."Web enquiry type") = 'to rent')
				OR (LOWER(v."Web Enquiry List") IN ('fs_contact','fs_results','fa_results','fa_contact') AND LOWER(v."Web enquiry type") = 'for sale')
				OR (LOWER(v."Web Enquiry List") IN ('aaa_contact','fa_results','fa_contact') AND LOWER(v."Web enquiry type") = 'lessor')
				OR (LOWER(v."Web Enquiry List") IN ('aaa_contact','fa_results','fa_contact') AND LOWER(v."Web enquiry type") = 'vendor')
				OR (LOWER(v."Web Enquiry List") IN ('aaa_contact','fa_results','fa_contact','fa_brochure') AND LOWER(v."Web enquiry type") = '(not set)') THEN 'UK Residential'
			ELSE 'Unknown' 
			END AS Market,
		CHECKSUM(ISNULL(v.PagePath,'na')) AS DimPagePathKey,
		v.VisitorID + '_' + CAST(v.VisitID AS CHAR(10)) AS SessionID,
		v.TransactionID,
		v.TotalPageviews
	FROM
	(
		/* Visits with web leads, deduped */
		SELECT
			d.profile_id AS profile_id,
			'Web lead' AS WebRecordType,
			CAST(CAST(LEFT(d.date,4) AS CHAR(4)) + '-' + SUBSTRING(CAST(d.date AS CHAR(8)),5,2) + '-' + CAST(RIGHT(d.date,2) AS CHAR(4)) AS DATE) AS "Visit Date",
			d.fullVisitorId AS VisitorID,
			d.visitId AS VisitID,
			LEFT(d.hits_transaction_transactionId,32) AS TransactionID,
			d.device_deviceCategory AS "Device Category",
			d.device_browser AS Browser,
			d.device_operatingSystem AS "Operating System",
			'N' AS "Native App",
			d.geoNetwork_continent AS "User Continent",
			d.geoNetwork_subContinent AS "User Subcontinent",
			d.geoNetwork_country AS "User Country",
			d.hits_page_hostname AS Hostname,
			CASE 
				WHEN d.hits_page_hostname LIKE '%zoopla%' THEN 'Zoopla'
				WHEN d.hits_page_hostname LIKE '%primelocation%' THEN 'PrimeLocation'
				ELSE 'Other' 
				END AS Brand,
			d.hits_page_pagePath AS PagePath,
			d.trafficSource_source AS "Traffic Source",
			d.trafficSource_medium AS "Traffic Medium",
			d.trafficSource_campaign AS "Visit Campaign",
			d.hits_product_v2ProductCategory AS "Web Enquiry Type",
			d.hits_product_v2ProductName AS "Web Enquiry List",	
			CASE
				WHEN LOWER(d.trafficSource_medium) LIKE '%feed%'
					OR LOWER(d.trafficSource_source) IN ('nest','trov','adzuna','mitula','nuroa','newsnow','placebuzz') THEN 'Aggregators'
				WHEN LOWER(d.trafficSource_medium) LIKE 'commercial%' THEN 'Commercial'
				WHEN LOWER(d.trafficSource_medium) = '(none)' THEN 'Direct'
				WHEN LOWER(d.trafficSource_medium) = 'display' THEN 'Display'
				WHEN LOWER(d.trafficSource_medium) = 'email' THEN 'Email'
				WHEN LOWER(d.trafficSource_medium) = 'network' THEN 'Network'
				WHEN LOWER(d.trafficSource_medium) = 'organic' THEN 'Organic Search'
				WHEN LOWER(d.trafficSource_medium) = 'cpc' THEN 'Paid Search'
				WHEN LOWER(d.trafficSource_medium) = 'cpc' 
					AND LOWER(d.trafficSource_source) = 'facebook' THEN 'Paid Social'
				WHEN LOWER(d.trafficSource_medium) LIKE '%partnership%'
					OR LOWER(d.trafficSource_medium) LIKE '%api%'
					OR LOWER(d.trafficSource_medium) LIKE '%widget%'
					OR LOWER(d.trafficSource_medium) LIKE '%hlink%'
					OR LOWER(d.trafficSource_source) LIKE '%homesandproperty%'
					OR LOWER(d.trafficSource_source) LIKE '%indy%'
					OR LOWER(d.trafficSource_source) LIKE '%independent%' THEN 'Partnerships'
				WHEN LOWER(d.trafficSource_medium) = 'referral' THEN 'Referral'
				WHEN LOWER(d.trafficSource_source) LIKE '%twitter%'
					OR LOWER(d.trafficSource_source) LIKE '%facebook%'
					OR LOWER(d.trafficSource_source) LIKE '%pinterest%'
					OR LOWER(d.trafficSource_source) = 't.co'
					OR LOWER(d.trafficSource_medium) LIKE '%ads%'
					OR LOWER(d.trafficSource_medium) LIKE '%page post%' THEN 'Social'
				WHEN LOWER(d.trafficSource_medium) LIKE 'trade%' THEN 'Trade'
				ELSE '(Other)' 
				END AS "GA Channel",
			CASE
				WHEN LOWER(d.trafficSource_medium) LIKE '%feed%'
					OR LOWER(d.trafficSource_source) IN ('nest','trov','adzuna','mitula','nuroa','newsnow','placebuzz') THEN 'Aggregators'
				WHEN LOWER(d.trafficSource_medium) LIKE 'commercial%' THEN 'Commercial'
				WHEN LOWER(d.trafficSource_medium) = '(none)' THEN 'Direct'
				WHEN LOWER(d.trafficSource_medium) = 'display' THEN 'Display'
				WHEN LOWER(d.trafficSource_medium) = 'network' THEN 'Network'
				WHEN LOWER(d.trafficSource_medium) = 'email' THEN 'CRM'
				WHEN LOWER(d.trafficSource_medium) = 'organic' THEN 'SEO'
				WHEN LOWER(d.trafficSource_medium) = 'cpc' THEN 'PPC'
				WHEN LOWER(d.trafficSource_medium) LIKE '%partnership%'
					OR LOWER(d.trafficSource_medium) LIKE '%api%'
					OR LOWER(d.trafficSource_medium) LIKE '%widget%'
					OR LOWER(d.trafficSource_medium) LIKE '%hlink%'
					OR LOWER(d.trafficSource_source) LIKE '%homesandproperty%'
					OR LOWER(d.trafficSource_source) LIKE '%indy%'
					OR LOWER(d.trafficSource_source) LIKE '%independent%' THEN 'Partnerships'
				WHEN LOWER(d.trafficSource_medium) = 'referral' THEN 'Referral'
				WHEN LOWER(d.trafficSource_source) LIKE '%twitter%'
					OR LOWER(d.trafficSource_source) LIKE '%facebook%'
					OR LOWER(d.trafficSource_source) LIKE '%pinterest%'
					OR LOWER(d.trafficSource_source) = 't.co'
					OR LOWER(d.trafficSource_medium) LIKE '%ads%'
					OR LOWER(d.trafficSource_medium) LIKE '%page post%' THEN 'Social'
				WHEN LOWER(d.trafficSource_medium) LIKE 'trade%' THEN 'Trade'
				ELSE 'Other' 
				END AS "ZPG Channel",
			ISNULL(d.hits_product_v2ProductCategory,'na') + '_' + ISNULL(d.hits_product_v2ProductName,'na') AS EnquiryTypeKey,
			d.totals_pageviews AS TotalPageviews,
			d.totals_newVisits AS NewVisits,
			CASE
				WHEN d.totals_newVisits = 1 THEN 'True'
				ELSE 'False'
				END AS "New Visitor",
			CASE 
				WHEN d.totals_newVisits = 1 THEN 'New'
				ELSE 'Returning'
				END AS "Visitor Type"
		FROM 
		(/* sticky TransactionID with same VisitID */
			SELECT 
				[profile_id],
				date,
				[device_browser],
				[device_deviceCategory],
				[device_operatingSystem],
				[fullVisitorId],
				[geoNetwork_continent],
				[geoNetwork_country],
				[geoNetwork_subContinent],
				[hits_hitNumber],
				[hits_time],
				[hits_hour],
				[hits_minute],
				[hits_page_hostname],
				[hits_page_pagePath],
				[hits_product_v2ProductCategory],
				[hits_product_v2ProductName],
				[hits_transaction_transactionId],
				[trafficSource_campaign],
				[trafficSource_medium],
				[trafficSource_source],
				[trafficSource_referralPath],
				[visitId],
				[visitNumber],
				[visitStartTime],
				[totals_hits],
				[totals_pageviews],
				[totals_timeOnSite],
				[totals_newVisits],
				[totals_UniqueScreenViews]
			FROM 
			(	--ordering by hit number to find 1st row with actual TransactionID
				SELECT 
					*,
					ROW_NUMBER() OVER (PARTITION BY w.hits_transaction_transactionId ORDER BY w.hits_hitNumber) AS RowID
				FROM source.ga_leads_no_native_app w
				WHERE 
					CAST(CAST(LEFT(w.date,4) AS CHAR(4)) + '-' + SUBSTRING(CAST(w.date AS CHAR(8)),5,2) + '-' + CAST(RIGHT(w.date,2) AS CHAR(4)) AS date) >= CURRENT_DATE - INTERVAL '1 days' AND
					w.hits_transaction_transactionId IN
					--FROM those rows WHERE the multiples transaction IDs occur IN a single session
					(
						SELECT w.hits_transaction_transactionId
						FROM source.ga_leads_no_native_app w
						WHERE CAST(CAST(LEFT(w.date,4) AS CHAR(4)) + '-' + SUBSTRING(CAST(w.date AS CHAR(8)),5,2) + '-' + CAST(RIGHT(w.date,2) AS CHAR(4)) AS date) >= CURRENT_DATE - INTERVAL '1 days' 
						GROUP BY w.hits_transaction_transactionId
						HAVING COUNT(DISTINCT (w.fullVisitorId + '_' + CAST(w.VisitID AS CHAR(10))))=1
					)
			) w
			WHERE w.RowID=1
			
			UNION ALL
			
			/* sticky TransactionID with different VisitID */
			SELECT 
				[profile_id],
				date,
				[device_browser],
				[device_deviceCategory],
				[device_operatingSystem],
				[fullVisitorId],
				[geoNetwork_continent],
				[geoNetwork_country],
				[geoNetwork_subContinent],
				[hits_hitNumber],
				[hits_time],
				[hits_hour],
				[hits_minute],
				[hits_page_hostname],
				[hits_page_pagePath],
				[hits_product_v2ProductCategory],
				[hits_product_v2ProductName],
				[hits_transaction_transactionId],
				[trafficSource_campaign],
				[trafficSource_medium],
				[trafficSource_source],
				[trafficSource_referralPath],
				[visitId],
				[visitNumber],
				[visitStartTime],
				[totals_hits],
				[totals_pageviews],
				[totals_timeOnSite],
				[totals_newVisits],
				[totals_UniqueScreenViews]
			FROM
			(	--ordering by hit number to find 1st row with actual TransactionID
				SELECT 
					*,
					ROW_NUMBER() OVER (PARTITION BY w.hits_transaction_transactionId ORDER BY w.hits_hitNumber) AS RowID
				FROM source.ga_leads_no_native_app w
				WHERE 
					CAST(CAST(LEFT(w.date,4) AS CHAR(4)) + '-' + SUBSTRING(CAST(w.date AS CHAR(8)),5,2) + '-' + CAST(RIGHT(w.date,2) AS CHAR(4)) AS date) >= CURRENT_DATE - INTERVAL '1 days' AND
					w.hits_transaction_transactionId IN
					--FROM those rows WHERE the multiples transaction IDs occur IN multiple sessions (changing VisitIDs)
					(
						SELECT w.hits_transaction_transactionId
						FROM source.ga_leads_no_native_app w
						WHERE CAST(CAST(LEFT(w.date,4) AS CHAR(4)) + '-' + SUBSTRING(CAST(w.date AS CHAR(8)),5,2) + '-' + CAST(RIGHT(w.date,2) AS CHAR(4)) AS date) >= CURRENT_DATE - INTERVAL '1 days' 
						GROUP BY w.hits_transaction_transactionId
						HAVING COUNT(DISTINCT (w.fullVisitorId + '_' + CAST(w.VisitID AS CHAR(10))))>1
					)
			) w
			WHERE w.RowID=1
		) d
		
		UNION ALL
		
		/* Visits with App Leads */
		SELECT 
			wl.profile_id AS profile_id,
			'App lead' AS WebRecordType,
			CAST(CAST(LEFT(wl.date,4) AS CHAR(4)) + '-' + SUBSTRING(CAST(wl.date AS CHAR(8)),5,2) + '-' + CAST(RIGHT(wl.date,2) AS CHAR(4)) AS DATE) AS "Visit Date",
			wl.fullVisitorId AS VisitorID,
			wl.visitId AS VisitID,
			LEFT(wl.hits_transaction_transactionId,32) AS TransactionID,
			wl.device_deviceCategory AS "Device Category",
			wl.device_browser AS Browser,
			wl.device_operatingSystem AS "Operating System",
			'Y' AS "Native App",
			wl.geoNetwork_continent AS "User Continent",
			wl.geoNetwork_subContinent AS "User Subcontinent",
			wl.geoNetwork_country AS "User Country",
			wl.hits_page_hostname AS Hostname,
			CASE 
				WHEN wl.hits_page_hostname LIKE '%zoopla%' THEN 'Zoopla'
				WHEN wl.hits_page_hostname LIKE '%primelocation%' THEN 'PrimeLocation'
				ELSE 'Other' 
				END AS Brand,
			wl.hits_page_pagePath AS PagePath,
			wl.trafficSource_source AS "Traffic Source",
			wl.trafficSource_medium AS "Traffic Medium",
			wl.trafficSource_campaign AS "Visit Campaign",
			wl.hits_item_productCategory AS "Web Enquiry Type",
			wl.hits_item_productName AS "Web Enquiry List",
			CASE
				WHEN LOWER(wl.trafficSource_medium) LIKE '%feed%'
					OR LOWER(wl.trafficSource_source) IN ('nest','trov','adzuna','mitula','nuroa','newsnow','placebuzz') THEN 'Aggregators'
				WHEN LOWER(wl.trafficSource_medium) LIKE 'commercial%' THEN 'Commercial'
				WHEN LOWER(wl.trafficSource_medium) = '(none)' THEN 'Direct'
				WHEN LOWER(wl.trafficSource_medium) = 'display' THEN 'Display'
				WHEN LOWER(wl.trafficSource_medium) = 'email' THEN 'Email'
				WHEN LOWER(wl.trafficSource_medium) = 'network' THEN 'Network'
				WHEN LOWER(wl.trafficSource_medium) = 'organic' THEN 'Organic Search'
				WHEN LOWER(wl.trafficSource_medium) = 'cpc' THEN 'Paid Search'
				WHEN LOWER(wl.trafficSource_medium) = 'cpc' 
					AND LOWER(wl.trafficSource_source) = 'facebook' THEN 'Paid Social'
				WHEN LOWER(wl.trafficSource_medium) LIKE '%partnership%'
					OR LOWER(wl.trafficSource_medium) LIKE '%api%'
					OR LOWER(wl.trafficSource_medium) LIKE '%widget%'
					OR LOWER(wl.trafficSource_medium) LIKE '%hlink%'
					OR LOWER(wl.trafficSource_source) LIKE '%homesandproperty%'
					OR LOWER(wl.trafficSource_source) LIKE '%indy%'
					OR LOWER(wl.trafficSource_source) LIKE '%independent%' THEN 'Partnerships'
				WHEN LOWER(wl.trafficSource_medium) = 'referral' THEN 'Referral'
				WHEN LOWER(wl.trafficSource_source) LIKE '%twitter%'
					OR LOWER(wl.trafficSource_source) LIKE '%facebook%'
					OR LOWER(wl.trafficSource_source) LIKE '%pinterest%'
					OR LOWER(wl.trafficSource_source) = 't.co'
					OR LOWER(wl.trafficSource_medium) LIKE '%ads%'
					OR LOWER(wl.trafficSource_medium) LIKE '%page post%' THEN 'Social'
				WHEN LOWER(wl.trafficSource_medium) LIKE 'trade%' THEN 'Trade'
				ELSE '(Other)' 
				END AS "GA Channel",
			CASE
				WHEN LOWER(wl.trafficSource_medium) LIKE '%feed%'
					OR LOWER(wl.trafficSource_source) IN ('nest','trov','adzuna','mitula','nuroa','newsnow','placebuzz') THEN 'Aggregators'
				WHEN LOWER(wl.trafficSource_medium) LIKE 'commercial%' THEN 'Commercial'
				WHEN LOWER(wl.trafficSource_medium) = '(none)' THEN 'Direct'
				WHEN LOWER(wl.trafficSource_medium) = 'display' THEN 'Display'
				WHEN LOWER(wl.trafficSource_medium) = 'network' THEN 'Network'
				WHEN LOWER(wl.trafficSource_medium) = 'email' THEN 'CRM'
				WHEN LOWER(wl.trafficSource_medium) = 'organic' THEN 'SEO'
				WHEN LOWER(wl.trafficSource_medium) = 'cpc' THEN 'PPC'
				WHEN LOWER(wl.trafficSource_medium) LIKE '%partnership%'
					OR LOWER(wl.trafficSource_medium) LIKE '%api%'
					OR LOWER(wl.trafficSource_medium) LIKE '%widget%'
					OR LOWER(wl.trafficSource_medium) LIKE '%hlink%'
					OR LOWER(wl.trafficSource_source) LIKE '%homesandproperty%'
					OR LOWER(wl.trafficSource_source) LIKE '%indy%'
					OR LOWER(wl.trafficSource_source) LIKE '%independent%' THEN 'Partnerships'
				WHEN LOWER(wl.trafficSource_medium) = 'referral' THEN 'Referral'
				WHEN LOWER(wl.trafficSource_source) LIKE '%twitter%'
					OR LOWER(wl.trafficSource_source) LIKE '%facebook%'
					OR LOWER(wl.trafficSource_source) LIKE '%pinterest%'
					OR LOWER(wl.trafficSource_source) = 't.co'
					OR LOWER(wl.trafficSource_medium) LIKE '%ads%'
					OR LOWER(wl.trafficSource_medium) LIKE '%page post%' THEN 'Social'
				WHEN LOWER(wl.trafficSource_medium) LIKE 'trade%' THEN 'Trade'
				ELSE 'Other' 
				END AS "ZPG Channel",
			ISNULL(wl.hits_item_productCategory,'na') + '_' + ISNULL(wl.hits_item_productName,'na') AS EnquiryTypeKey,
			wl.totals_pageviews AS TotalPageviews,
			wl.totals_newVisits AS NewVisits,
			CASE
				WHEN wl.totals_newVisits = 1 THEN 'True'
				ELSE 'False'
				END AS "New Visitor",
			CASE 
				WHEN wl.totals_newVisits = 1 THEN 'New'
				ELSE 'Returning'
				END AS "Visitor Type"
		FROM source.ga_leads_native_app wl
		WHERE CAST(CAST(LEFT(wl.date,4) AS CHAR(4)) + '-' + SUBSTRING(CAST(wl.date AS CHAR(8)),5,2) + '-' + CAST(RIGHT(wl.date,2) AS CHAR(4)) AS date) >= CURRENT_DATE - INTERVAL '1 days'
		
		UNION ALL
		
		/* Visits with no leads */
		SELECT 
			wl.profile_id AS profile_id,
			'Session' AS WebRecordType,
			CAST(CAST(LEFT(wl.date,4) AS CHAR(4)) + '-' + SUBSTRING(CAST(wl.date AS CHAR(8)),5,2) + '-' + CAST(RIGHT(wl.date,2) AS CHAR(4)) AS DATE) AS "Visit Date",
			wl.fullVisitorId AS VisitorID,
			wl.visitId AS VisitID,
			NULL AS TransactionID,
			wl.device_deviceCategory AS "Device Category",
			wl.device_browser AS Browser,
			wl.device_operatingSystem AS "Operating System",
			CASE WHEN wl.hits_appInfo_appName IS NULL THEN 'N' ELSE 'Y' END AS "Native App",
			wl.geoNetwork_continent AS "User Continent",
			wl.geoNetwork_subContinent AS "User Subcontinent",
			wl.geoNetwork_country AS "User Country",
			wl.hits_page_hostname AS Hostname,
			CASE 
				WHEN wl.hits_page_hostname LIKE '%zoopla%' THEN 'Zoopla'
				WHEN wl.hits_page_hostname LIKE '%primelocation%' THEN 'PrimeLocation'
				ELSE 'Other' 
				END AS Brand,
			NULL AS PagePath,
			wl.trafficSource_source AS "Traffic Source",
			wl.trafficSource_medium AS "Traffic Medium",
			wl.trafficSource_campaign AS "Visit Campaign",
			NULL AS "Web Enquiry Type",
			NULL AS "Web Enquiry List",
			CASE
				WHEN LOWER(wl.trafficSource_medium) LIKE '%feed%'
					OR LOWER(wl.trafficSource_source) IN ('nest','trov','adzuna','mitula','nuroa','newsnow','placebuzz') THEN 'Aggregators'
				WHEN LOWER(wl.trafficSource_medium) LIKE 'commercial%' THEN 'Commercial'
				WHEN LOWER(wl.trafficSource_medium) = '(none)' THEN 'Direct'
				WHEN LOWER(wl.trafficSource_medium) = 'display' THEN 'Display'
				WHEN LOWER(wl.trafficSource_medium) = 'email' THEN 'Email'
				WHEN LOWER(wl.trafficSource_medium) = 'network' THEN 'Network'
				WHEN LOWER(wl.trafficSource_medium) = 'organic' THEN 'Organic Search'
				WHEN LOWER(wl.trafficSource_medium) = 'cpc' THEN 'Paid Search'
				WHEN LOWER(wl.trafficSource_medium) = 'cpc' 
					AND LOWER(wl.trafficSource_source) = 'facebook' THEN 'Paid Social'
				WHEN LOWER(wl.trafficSource_medium) LIKE '%partnership%'
					OR LOWER(wl.trafficSource_medium) LIKE '%api%'
					OR LOWER(wl.trafficSource_medium) LIKE '%widget%'
					OR LOWER(wl.trafficSource_medium) LIKE '%hlink%'
					OR LOWER(wl.trafficSource_source) LIKE '%homesandproperty%'
					OR LOWER(wl.trafficSource_source) LIKE '%indy%'
					OR LOWER(wl.trafficSource_source) LIKE '%independent%' THEN 'Partnerships'
				WHEN LOWER(wl.trafficSource_medium) = 'referral' THEN 'Referral'
				WHEN LOWER(wl.trafficSource_source) LIKE '%twitter%'
					OR LOWER(wl.trafficSource_source) LIKE '%facebook%'
					OR LOWER(wl.trafficSource_source) LIKE '%pinterest%'
					OR LOWER(wl.trafficSource_source) = 't.co'
					OR LOWER(wl.trafficSource_medium) LIKE '%ads%'
					OR LOWER(wl.trafficSource_medium) LIKE '%page post%' THEN 'Social'
				WHEN LOWER(wl.trafficSource_medium) LIKE 'trade%' THEN 'Trade'
				ELSE '(Other)' 
				END AS "GA Channel",
			CASE
				WHEN LOWER(wl.trafficSource_medium) LIKE '%feed%'
					OR LOWER(wl.trafficSource_source) IN ('nest','trov','adzuna','mitula','nuroa','newsnow','placebuzz') THEN 'Aggregators'
				WHEN LOWER(wl.trafficSource_medium) LIKE 'commercial%' THEN 'Commercial'
				WHEN LOWER(wl.trafficSource_medium) = '(none)' THEN 'Direct'
				WHEN LOWER(wl.trafficSource_medium) = 'display' THEN 'Display'
				WHEN LOWER(wl.trafficSource_medium) = 'network' THEN 'Network'
				WHEN LOWER(wl.trafficSource_medium) = 'email' THEN 'CRM'
				WHEN LOWER(wl.trafficSource_medium) = 'organic' THEN 'SEO'
				WHEN LOWER(wl.trafficSource_medium) = 'cpc' THEN 'PPC'
				WHEN LOWER(wl.trafficSource_medium) LIKE '%partnership%'
					OR LOWER(wl.trafficSource_medium) LIKE '%api%'
					OR LOWER(wl.trafficSource_medium) LIKE '%widget%'
					OR LOWER(wl.trafficSource_medium) LIKE '%hlink%'
					OR LOWER(wl.trafficSource_source) LIKE '%homesandproperty%'
					OR LOWER(wl.trafficSource_source) LIKE '%indy%'
					OR LOWER(wl.trafficSource_source) LIKE '%independent%' THEN 'Partnerships'
				WHEN LOWER(wl.trafficSource_medium) = 'referral' THEN 'Referral'
				WHEN LOWER(wl.trafficSource_source) LIKE '%twitter%'
					OR LOWER(wl.trafficSource_source) LIKE '%facebook%'
					OR LOWER(wl.trafficSource_source) LIKE '%pinterest%'
					OR LOWER(wl.trafficSource_source) = 't.co'
					OR LOWER(wl.trafficSource_medium) LIKE '%ads%'
					OR LOWER(wl.trafficSource_medium) LIKE '%page post%' THEN 'Social'
				WHEN LOWER(wl.trafficSource_medium) LIKE 'trade%' THEN 'Trade'
				ELSE 'Other' 
				END AS "ZPG Channel",
			NULL AS EnquiryTypeKey,
			wl.totals_pageviews AS TotalPageviews,
			wl.totals_newVisits AS NewVisits,
			CASE
				WHEN wl.totals_newVisits = 1 THEN 'True'
				ELSE 'False'
				END AS "New Visitor",
			CASE 
				WHEN wl.totals_newVisits = 1 THEN 'New'
				ELSE 'Returning'
				END AS "Visitor Type"
		FROM source.ga_sessions_no_lead wl
		WHERE CAST(CAST(LEFT(wl.date,4) AS CHAR(4)) + '-' + SUBSTRING(CAST(wl.date AS CHAR(8)),5,2) + '-' + CAST(right(wl.date,2) AS CHAR(4)) AS date) >= CURRENT_DATE - INTERVAL '1 days'
	) v
		LEFT JOIN source.ga_visit_platform p 
			ON v."Visit Date" = CAST(CAST(LEFT(p.date,4) AS CHAR(4)) + '-' + SUBSTRING(CAST(p.date AS CHAR(8)),5,2) + '-' + CAST(RIGHT(p.date,2) AS CHAR(4)) AS DATE)
			AND v.visitorid = p.fullvisitorid
			AND v.visitid = p.visitid
	WHERE CAST(CAST(LEFT(p.date,4) AS CHAR(4)) + '-' + SUBSTRING(CAST(p.date AS CHAR(8)),5,2) + '-' + CAST(RIGHT(p.date,2) AS CHAR(4)) AS date) >= CURRENT_DATE - INTERVAL '1 days'
) allvisits