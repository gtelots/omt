## OpenMapTiles

## Develop
### Workflow to generate tiles
If you go from top to bottom you can be sure that it will generate a .mbtiles file out of a .osm.pbf file
```
make clean                  # clean / remove existing build files
make                        # generate build files
make start-db               # start up the database container.
make import-data            # Import external data from OpenStreetMapData, Natural Earth and OpenStreetMap Lake Labels.
make download-fonts
make download-geofabrik area=vietnam  # download vietnam .osm.pbf file -- can be skipped if a .osm.pbf file already existing
make import-osm             # import data into postgres
make import-wikidata        # import Wikidata
make import-sql             # create / import sql functions 
make generate-bbox-file     # compute data bbox -- not needed for the whole planet or for downloaded area by `make download`
make generate-tiles-pg      # generate tiles


make start-maputnik
make start-postserve
make start-tileserver
```
Instead of calling `make download area=vietnam` you can add a .osm.pbf file in the `data` folder `openmaptiles/data/your_area_file.osm.pbf`

To change the name of the output filename, you can modify the variable `MBTILES_FILE` in the `.env` file or set up the environment variable `MBTILES_FILE` before running `./quickstart.sh` or `make generate-tiles-pg` (e.g., `MBTILES_FILENAME=vietnam.mbtiles ./quickstart.sh vietnam`).