SELECT 
	d.date1 listing_date,   
    slpa.country_code,
    slpa.category,
    slpa.transaction_type,
    'UK residential' AS Sales_channel,
    COUNT(DISTINCT NVL(mll.master_listing_id, slpa.listing_id)) AS totallistings
FROM 
	source_agent_branch_details_nopii AS sabd
    INNER JOIN source.source_listing_primary_attributes_head AS slpa 
        ON LOWER(sabd.source_branch_id) = LOWER(slpa.source_branch_id) AND LOWER(sabd.source) = LOWER(slpa.source)
    INNER JOIN source.listings_publish_listing_history AS h 
        ON h.listing_id = slpa.listing_id
    INNER JOIN source.listing_date_lookup AS d 
        ON h.start_date < d.date2 AND NVL(h.end_date, '31-DEC-2099') >= d.date2
    LEFT OUTER JOIN source.matched_listings_lookup AS mll 
        ON mll.matched_listing_id = slpa.listing_id
    INNER JOIN source.agent_branches_nopii AS ab 
        ON ab.branch_id = sabd.internal_branch_id
WHERE 
	d.date1 >= '28-SEP-2014' 
	AND d.date1 < CURRENT_DATE - INTERVAL '0 days' 
    AND category != 'commercial'
    AND slpa.country_code = 'gb'
GROUP BY
    d.date1,
    slpa.country_code,
    slpa.category,
    slpa.transaction_type
UNION ALL
SELECT
	d.date1 listing_date,
	slpa.country_code, 
	slpa.category, 
	slpa.transaction_type,
	'Developers' AS Sales_channel,
	COUNT(DISTINCT NVL(mll.master_listing_id, slpa.listing_id)) AS totallistings
FROM 
	source.source_agent_branch_details_nopii AS sabd
    INNER JOIN source.source_listing_primary_attributes_head AS slpa 
        ON LOWER(sabd.source_branch_id) = LOWER(slpa.source_branch_id) AND LOWER(sabd.source) = LOWER(slpa.source)
    INNER JOIN source.listings_publish_listing_history AS h 
        ON h.listing_id = slpa.listing_id
    INNER JOIN source.listing_date_lookup AS d 
        ON h.start_date < d.date2 AND NVL(h.end_date, '31-DEC-2099') >= d.date2
    LEFT OUTER JOIN source.matched_listings_lookup AS mll 
        ON mll.matched_listing_id = slpa.listing_id
    INNER JOIN source.agent_branches_nopii AS ab 
        ON ab.branch_id = sabd.internal_branch_id    
WHERE 
	d.date1 >= '28-SEP-2014' 
	AND d.date1 < CURRENT_DATE - INTERVAL '0 days'   
	AND ab.branch_id IN 
		(	SELECT c.branch_id
			FROM source.contracts_migration AS c
				INNER JOIN source.agent_packages AS p 
					ON p.agent_package_id = c.agent_package_id
				INNER JOIN source.agent_branches_nopii AS b ON b.branch_id = c.branch_id
			WHERE package_type = 'developer'
		)
GROUP BY 
	d.date1,
    slpa.country_code,
    slpa.category,
    slpa.transaction_type
UNION ALL
SELECT 
	d.date1 listing_date,
    slpa.country_code,
    slpa.category,
    slpa.transaction_type,
    'Commercial' AS Sales_channel,
    COUNT(DISTINCT NVL(mll.master_listing_id, slpa.listing_id)) AS totallistings
FROM 
	source.source_agent_branch_details_nopii AS sabd
    INNER JOIN source.source_listing_primary_attributes_head AS slpa 
        ON LOWER(sabd.source_branch_id) = LOWER(slpa.source_branch_id) AND LOWER(sabd.source) = LOWER(slpa.source)
    INNER JOIN source.listings_publish_listing_history AS h 
        ON h.listing_id = slpa.listing_id
    INNER JOIN source.listing_date_lookup AS d 
        ON h.start_date < d.date2 AND NVL(h.end_date, '31-DEC-2099') >= d.date2
    LEFT OUTER JOIN source.matched_listings_lookup AS mll 
        ON mll.matched_listing_id = slpa.listing_id
    INNER JOIN source.agent_branches_nopii AS ab 
        ON ab.branch_id = sabd.internal_branch_id
WHERE 
	d.date1 >= '28-SEP-2014' 
	AND d.date1 < CURRENT_DATE - INTERVAL '0 days' 
    AND category = 'commercial'
GROUP BY
    d.date1,
    slpa.country_code,
    slpa.category,
    slpa.transaction_type
UNION ALL
SELECT 
	d.date1 listing_date,
    slpa.country_code,
    slpa.category,
    slpa.transaction_type,
    'Overseas' AS Sales_channel,
    COUNT(DISTINCT NVL(mll.master_listing_id, slpa.listing_id)) AS totallistings
FROM 
	source.source_agent_branch_details_nopii AS sabd
    INNER JOIN source.source_listing_primary_attributes_head AS slpa 
        ON LOWER(sabd.source_branch_id) = LOWER(slpa.source_branch_id) AND LOWER(sabd.source) = LOWER(slpa.source)
    INNER JOIN source.listings_publish_listing_history AS h 
        ON h.listing_id = slpa.listing_id
    INNER JOIN source.listing_date_lookup AS d 
        ON h.start_date < d.date2 AND NVL(h.end_date, '31-DEC-2099') >= d.date2
    LEFT OUTER JOIN source.matched_listings_lookup AS mll 
        ON mll.matched_listing_id = slpa.listing_id
    INNER JOIN source.agent_branches_nopii AS ab 
        ON ab.branch_id = sabd.internal_branch_id
WHERE 
	d.date1 >= '28-SEP-2014' 
	AND d.date1 < CURRENT_DATE - INTERVAL '0 days' 
    AND slpa.country_code != 'gb'
GROUP BY
    d.date1,
    slpa.country_code,
    slpa.category,
    slpa.transaction_type