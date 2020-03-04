#!/bin/bash
# bash script to generate tiles for house prices for small areas
# to run houseprice.sh


#You need the

#prepare your houseprice.csv
#remove top rows
#rename house price column as houseprice
#remove unnecessary columns, only need LSOAcode, LSOAname and houseprice

#unzip the buildings
echo 'unzipping buildings'
unzip OSdistrictByLSOA.zip


#join buildings to house price data
echo 'joining buildings to house price data'
mapshaper-xl OSdistrictByLSOA.shp -join houseprice.csv keys=lsoa11cd,LSOAcode field-types=LSOAcode:str,houseprice:num -o joined.shp


#reduce precisions
mapshaper-xl joined.shp precision=0.0001 -o reducedprecisions.shp

echo 'converting to geojson'
#convert to geojson
#this will take a while
ogr2ogr -f GeoJSON -t_srs crs:84 -lco COORDINATE_PRECISION=5 houseprices.geojson joined.shp

echo 'generating tiles'
#Make the tiles
#Zoom level 4 to 8
tippecanoe --minimum-zoom=4 --maximum-zoom=9 --output-to-directory z4-8 --full-detail=9 --drop-smallest-as-needed --extend-zooms-if-still-dropping houseprices.geojson
#Zoom level 9
tippecanoe --minimum-zoom=9 --maximum-zoom=9 --output-to-directory z9 --full-detail=11 --no-tile-size-limit houseprices.geojson
#Zoom 10 to 13
tippecanoe --minimum-zoom=10 --maximum-zoom=13 --output-to-directory z10-13 --no-tile-size-limit --extend-zooms-if-still-dropping houseprices.geojson


#move the files together
mkdir tiles
cp -r z4-8/ tiles
cp -r z9/ tiles
cp -r z10-13/ tiles

echo 'downloading LSOA boundaries'
#download generalised lsoa geojson
wget https://opendata.arcgis.com/datasets/007577eeb8e34c62a1844df090a93128_0.geojson

echo 'rename file'
#ogr2ogr didn't take kindly to a string beginning with a number
mv 007577eeb8e34c62a1844df090a93128_0.geojson msoaboundaries.geojson

echo 'joining house prices to LSOA boundaries'
#drop fields we don't need
ogr2ogr -f geojson -t_srs crs:84 -sql "SELECT lsoa11cd, lsoa11nm FROM msoaboundaries" bounds.geojson msoaboundaries.geojson

#join house prices to boundaries too
mapshaper-xl bounds.geojson -join houseprice.csv keys=lsoa11cd,LSOAcode field-types=LSOAcode:str,houseprice:num -o boundar.geojson

#drop some more fields
ogr2ogr -f geojson -t_srs crs:84 -sql "SELECT lsoa11cd, lsoa11nm, houseprice FROM boundar" boundaries.geojson boundar.geojson

#tidy up
rm bounds.geojson
rm boundar.geojson

echo 'making LSOA boundaries tiles'
#makes tiles for the lsoa boundaries
tippecanoe --minimum-zoom=10 --maximum-zoom=13 --output-to-directory boundaries --no-tile-size-limit boundaries.geojson

echo 'zipping up files, almost done'
#zip the files up for EC2
zip -r tiles.zip tiles boundaries
echo 'DONE!'
