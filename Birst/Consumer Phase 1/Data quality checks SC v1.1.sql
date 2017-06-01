/* Check Platform */

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
SET platform = 'Responsive'
WHERE platform = 'responsive';

UPDATE staging.fullfeed
SET platform = 'Unknown'
WHERE platform = ' ';

/* Check Device and Device Category */

UPDATE staging.fullfeed
SET device = 'Unknown'
WHERE device = 'na';

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
SET "device category" = 'Unknown'
WHERE "device category" IS NULL;

/* Check Market and Market Type */

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
SET market = 'Commercial'
WHERE markettype = 'Commercial';

UPDATE staging.fullfeed
SET markettype = 'Unknown', market = 'Unknown'
WHERE market = 'na';

UPDATE staging.fullfeed
SET markettype = 'Unknown'
WHERE markettype IS NULL;

UPDATE staging.fullfeed
SET markettype = 'Unknown'
WHERE markettype = 'unknown';

