Fancy script to generate tiles for the House Price and Small Area map.

Prequistives: mapshaper, gdal, tippecanoe, wget

You need a .csv with the house price column named as `houseprice` and to have the first row as column names. 

Run `sh houseprice.sh` to start generating the tiles

Run `sh upload PUBLIC-DNS` to upload and unzip the tiles to your EC2 instance

There's some test html files in there that will need a server than can run gzip compression e.g. live-server with some middleware
