SELECT name, installed_version, default_version
FROM pg_available_extensions
WHERE name IN (
  'postgis',
  'fuzzystrmatch',
  'hstore',
  'unaccent',
  'osml10n',
  'gzip',
  'pgrouting'
)
ORDER BY name;

SELECT extname, extversion
FROM pg_extension
WHERE extname IN (
  'postgis',
  'fuzzystrmatch',
  'hstore',
  'unaccent',
  'osml10n',
  'gzip'
)
ORDER BY extname;

SHOW jit;
