/* Check Device, Market, Market Type, Device Category */

UPDATE staging.fullfeed
SET platform = 'Mobile'
WHERE platform in ('m','mo','mob','mobi','mobil','mobile');

UPDATE staging.fullfeed
SET platform = 'App'
WHERE platform in ('app');

UPDATE staging.fullfeed
SET platform = 'Desktop'
WHERE platform in ('d','desk','deskto','desktop');

UPDATE staging.fullfeed
SET platform = 'Native App'
WHERE platform in ('native-app');

UPDATE staging.fullfeed
SET platform = 'Unknown'
WHERE platform = ' ';

UPDATE staging.fullfeed



UPDATE staging.fullfeed
SET device = 'Unknown'
WHERE device = 'na';

UPDATE staging.fullfeed
SET "device category" = 'Unknown'
WHERE "device category" IS NULL;

UPDATE staging.fullfeed
SET "device category" = 'Desktop'
WHERE "device category" = 'desktop';

UPDATE staging.fullfeed
SET "device category" = 'Mobile'
WHERE "device category" = 'mobile';

UPDATE staging.fullfeed
SET "device category" = 'Tablet'
WHERE "device category" = 'tablet';

UPDATE staging.fullfeed
SET device = 'Unknown', "device category" = 'Unknown', platform = 'Unknown'
where platform ='App'
and lead = 'Phone';

UPDATE staging.fullfeed
SET market = 'Unknown'
---, markettype = 'Unknown'
WHERE market = 'na';


UPDATE staging.fullfeed
SET market = 'Unknown', markettype = 'Unknown'
WHERE enquirytypekey = '(not set)__Results';

UPDATE staging.fullfeed
SET market = 'UK Residential Valuation', markettype = 'UK Residential Valuation'
WHERE enquirytypekey = 'Estimate run_Estimate';

UPDATE staging.fullfeed
SET market = 'Unknown', markettype = 'Unknown'
WHERE market = 'na' and enquirytypekey = '_'

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '(not set)_AAA_Contact';

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '(not set)_FA_Contact';

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '(not set)_FA_Results';

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '_AAA_Contact';

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '_FA_Brochure';

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '_FA_Contact';

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '_FS_Results';

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '_TR_Result';

UPDATE staging.fullfeed
SET market = 'Commercial', markettype = 'Commercial'
WHERE enquirytypekey = 'Commercial Let__Results';

UPDATE staging.fullfeed
SET market = 'Commercial', markettype = 'Commercial'
WHERE enquirytypekey = 'Commercial Let_FA_Results';

UPDATE staging.fullfeed
SET market = 'Commercial', markettype = 'Commercial'
WHERE enquirytypekey = 'Commercial Sale__Results';

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'For Sale__Brochure';

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'For Sale__Results';


UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'For Sale_FS_Results_Contact';

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'For Sale_TR_Contact';

UPDATE staging.fullfeed
SET market = 'Developer', markettype = 'Developer'
WHERE enquirytypekey = 'Lessor_NH_Contact';

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'To Rent_FS_Contact'

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'To Rent_FS_Results_Contact'

UPDATE staging.fullfeed
SET market = 'Developer', markettype = 'Developer'
WHERE enquirytypekey = 'To Rent_NH_Contact'

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'To Rent_TR_Brochure'

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'To Rent_TR_Results_Contact'

UPDATE staging.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'To%20Rent_TR_Contact'

UPDATE staging.fullfeed
SET market = 'Developer', markettype = 'Developer'
WHERE enquirytypekey = 'Vendor_NH_Contact'



UPDATE staging.fullfeed
SET markettype = 'UK Residential'
WHERE market = 'UK Residential';

UPDATE staging.fullfeed
SET market = 'UK Residential'
WHERE markettype = 'UK Residential';

UPDATE staging.fullfeed
SET markettype = 'Commercial'
WHERE market = 'Commercial';


UPDATE staging.fullfeed
SET markettype = 'Unknown', market = 'Unknown'
WHERE market = 'na';

UPDATE staging.fullfeed
SET markettype = 'Unknown'
WHERE markettype IS NULL;

UPDATE staging.fullfeed
SET markettype = 'Unknown'
WHERE markettype = 'unknown';


select markettype, market
from staging.fullfeed
group by markettype,market

select platform, sum(fullfeed.noofvisits)
from staging.fullfeed
group by fullfeed.platform