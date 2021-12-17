################################################################################
################################################################################
### ROCHELLE SCHNEIDER DOS SANTOS
### 
### ============================================================================
### ERA5 / ERA5 Land - 2m TEMPERATURE (STUK PROJECT - STAGE 3)
### ============================================================================
### R SCRIPT FOR:
### * CREATE LOOK UP TABLE FROM ERA-5 2mTemp NETCDF WITH THE 1KM OSGRID
### * DETECT THE ERA-5 GRID CELLS INSIDE GB 
### * EXTRACT THE ERA-5 data (Temp) BY GRID CELL 
################################################################################
################################################################################

## \\\\\\\\\\\\\\ ##
## \\\\ ERA 5 \\\ ## 
## \\\\\\\\\\\\\\ ##
library(raster) ; library(rgdal) ;library(ncdf4) ; library(sf);library(sp);
library(stringr); library(data.table); library(maptools) ; library(lubridate)

#============================================================##
## ==== CREATE LOOK UP TABLE FROM ERA-5 NETCDF ==============##
## ==== DETECT THE ERA-5 GRID CELLS INSIDE GB ===============##
#============================================================##

setwd ("/Users/aurelianosancho/Documents/GitHub/ERA5_download_and_table/Data/")

####  GREAT BRITAIN BOUNDARY - GEOG + PROJECTION BNG
poly <- sf::read_sf("/Users/aurelianosancho/Documents/GitHub/ERA5_download_and_table/Data/BR_UF_2020.shp")

#############################
## \\\\\\\\\ T2m \\\\\\\\\ ##
#############################

### IT IS ONLY ONE FILE WITH ALL 2m TEMP
nc <- nc_open("/Users/aurelianosancho/Documents/GitHub/ERA5_download_and_table/Data/temp_era5.nc") 

dname <- names(nc$var)[1] #"t2m" 

temp <- brick(nc[[1]], varname=dname, stopIfNotEqualSpaced=FALSE)

dim(temp) #161 157  30
temp.day <- temp[[1]] ## nao entendi
plot(temp.day)
crs(temp)

erat.df <- as.data.frame(temp[[1]], xy=TRUE, centroids=TRUE)
head(erat.df)
nrow(erat.df) #25277 (ALL PIXELS)

## INCLUDE THE ID CELL
erat.df$era5.id <- as.numeric(rownames(erat.df)) 
erat.df
## FROM DATA.FRAME TO DATA.TABLE
erat.df <- data.table(erat.df)
## FROM DATA.TABLE TO SHAPEFILE
erat.shp <- st_as_sf(erat.df, coords = c("x", "y"), crs = "+proj=longlat +datum=WGS84 +no_defs")
erat.shp <- sf::st_transform(erat.shp, st_crs(poly))
erat.shp
## SELECT THE POINTS LOCATED INSIDE 
erat.br = erat.shp[poly, ]
nrow(data.frame(erat.br)) 
sf::st_write(erat.br,"/Users/aurelianosancho/Documents/GitHub/ERA5_download_and_table/Data/ERA5_2mt_BR_GRS80.shp",driver = "ESRI Shapefile")


#=========================================================================##
#=========================================================================##
##== IDENTIFY THE CLOSEST ERA5 GRID-CENTROID FROM EACH OS.GRID-CENTROID ==##
#=========================================================================##
#=========================================================================##

## GET THE NEAREST ERA5 GRID CELL FOR EACH OS.GRID
grid.era = st_join(poly, erat.br)

head(data.frame(grid.era))
nrow(data.frame(grid.era))

grid.eradf <- data.frame(grid.era)
length(unique(grid.era$era5.id)) 

grid.eradf <- grid.eradf[ , -c(5:6)]
names(grid.eradf)
head(grid.eradf)

saveRDS(grid.eradf, "H:\\Desktop\\Rochelle_LSHTMdesktop\\Space4health_Brazil\\processed\\UF_era5id_lookup.RDS")


###CREATE A LOOKUP TABLE IN A SHAPEFILEFORMAT
grid.era.shp <- merge(erat.shp, grid.eradf, by="era5.id")
head(grid.era.shp)
sf::st_write(grid.era.shp,"H:\\Desktop\\Rochelle_LSHTMdesktop\\Space4health_Brazil\\shapefile\\ERA5_BR_GRS80_pt.shp",driver = "ESRI Shapefile")


## \\\\\\\\\\\\\\\\\\\##
## \\\\ ERA 5 Land \\\ ## 
## \\\\\\\\\\\\\\\\\\\ ##

#============================================================##
## ==== CREATE LOOK UP TABLE FROM ERA-5land NETCDF ==============##
## ==== DETECT THE ERA-5land GRID CELLS INSIDE GB ===============##
#============================================================##

#############################
## \\\\\\\\\ T2m \\\\\\\\\ ##
#############################

### IT IS ONLY ONE FILE WITH ALL 2m TEMP
files  <- "H:\\Desktop\\Rochelle_LSHTMdesktop\\Space4health_Brazil\\data\\temp_era5land.nc"

file.1 <- nc_open(files) 
file.1
## FROM "files.1" EXTRACT THE VARIABLES' NAME
dname <- names(file.1$var)[1] #"t2m" 

temp <- brick(file.1[[1]], varname=dname, stopIfNotEqualSpaced=FALSE)

dim(temp) #401 391   6
temp.day <- temp[[1]] 
plot(temp.day)
crs(temp)

erat.df <- as.data.frame(temp[[1]], xy=TRUE, centroids=TRUE)
head(erat.df)
nrow(erat.df) #156791 (ALL PIXELS)

## INCLUDE THE ID CELL
erat.df$era5land.id <- as.numeric(rownames(erat.df)) 
## FROM DATA.FRAME TO DATA.TABLE
erat.df <- data.table(erat.df)
## FROM DATA.TABLE TO SHAPEFILE
erat.shp<- st_as_sf(erat.df, coords = c("x", "y"), crs = "+proj=longlat +datum=WGS84 +no_defs")
erat.shp <- sf::st_transform(erat.shp, st_crs(poly))

## SELECT THE POINTS LOCATED INSIDE GREAT BRITAIN 
erat.br = erat.shp[poly, ]
nrow(data.frame(erat.br)) #70922
#sf::st_write(erat.br,"C:\\Users\\ppehrsch\\Desktop\\ESA\\PROJECTS\\Space4health_Brazil\\shapefile\\ERA5_2mt_BR_GRS80.shp",driver = "ESRI Shapefile")


#=========================================================================##
#=========================================================================##
##== IDENTIFY THE CLOSEST ERA5 GRID-CENTROID FROM EACH OS.GRID-CENTROID ==##
#=========================================================================##
#=========================================================================##

## GET THE NEAREST ERA5 GRID CELL FOR EACH OS.GRID
grid.era = st_join(poly, erat.br)

head(data.frame(grid.era))
nrow(data.frame(grid.era))

grid.eradf <- data.frame(grid.era)
length(unique(grid.era$era5land.id)) 

grid.eradf <- grid.eradf[ , -c(5:6)]
names(grid.eradf)
head(grid.eradf)

saveRDS(grid.eradf, "H:\\Desktop\\Rochelle_LSHTMdesktop\\Space4health_Brazil\\processed\\UF_era5idLand_lookup.RDS")


###CREATE A LOOKUP TABLE IN A SHAPEFILEFORMAT
grid.era.shp <- merge(erat.shp, grid.eradf, by="era5land.id")
head(grid.era.shp)
sf::st_write(grid.era.shp,"H:\\Desktop\\Rochelle_LSHTMdesktop\\Space4health_Brazil\\shapefile\\ERA5Land_BR_GRS80_pt.shp",driver = "ESRI Shapefile")
