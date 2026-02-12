# This script converts ncdf data into excel format
# Author : Lonjezo Folias
# Number : 265 992 888 003 

##################################################

# Loading  packages

packages <- c("ncdf4", "dplyr", "ggplot2", "chron", "lattice", "RColorBrewer" ) 

install_and_load <- function(packages) {
  for (package in packages) {
    if (!require(package, character.only = TRUE)) {
      install.packages(package)
      library(package, character.only = TRUE)
    }
  }
}


# Set the path to the c directory
ncpath = "C:/Users/user/Documents/Manu Scripts/Wisdom Proposal/Weather Data/"
csvpath = "C:/Users/user/Documents/Manu Scripts/Wisdom Proposal/Weather Data/"

# Ensure the directory exists
if (dir.exists(ncpath)) {
  print("The directory exists.")
} else {
  stop("The directory does not exist.")
}

# Set the filename
ncname <- "cru_ts4.07.1901.2022.tmp.dat"

ncfname <- paste(ncpath, ncname, ".nc", sep="")

# Print the full path to the netCDF file to check it
print(paste("The full path to the netCDF file is:", ncfname))



# Ensure the file exists
if (file.exists(ncfname)) {
  print("The file exists.")
} else {
  stop("The file does not exist.")
}

ncfname <- paste(ncpath, ncname, ".nc", sep="")

dname <- "tmp"  # note: tmp means tmpcipitation (not temporary)

ncin <- nc_open(ncfname)

print(ncin)
# get longitude and latitude
lon <- ncvar_get(ncin,"lon")
nlon <- dim(lon)
head(lon)
lat <- ncvar_get(ncin,"lat")
nlat <- dim(lat)
head(lat)
print(c(nlon,nlat))
# get time
time <- ncvar_get(ncin,"time")
tunits <- ncatt_get(ncin,"time","units")
tunits
nt <- dim(time)
nt
tmp <- ncvar_get(ncin,"tmp")
tmp_array <- ncvar_get(ncin,dname)
dlname <- ncatt_get(ncin,dname,"long_name")
dunits <- ncatt_get(ncin,dname,"units")
fillvalue <- ncatt_get(ncin,dname,"_FillValue")
dim(tmp_array)
# get global attributes
title <- ncatt_get(ncin,0,"title")
institution <- ncatt_get(ncin,0,"institution")
datasource <- ncatt_get(ncin,0,"source")
references <- ncatt_get(ncin,0,"references")
history <- ncatt_get(ncin,0,"history")
Conventions <- ncatt_get(ncin,0,"Conventions")
#nc_close()
ls()

library(chron)
library(lattice)
library(RColorBrewer)


# convert time -- split the time units string into fields
tustr <- strsplit(tunits$value, " ")
tdstr <- strsplit(unlist(tustr)[3], "-")
tmonth <- as.integer(unlist(tdstr)[2])
tday <- as.integer(unlist(tdstr)[3])
tyear <- as.integer(unlist(tdstr)[1])
chron(time,origin=c(tmonth, tday, tyear))

# replace netCDF fill values with NA's
tmp_array[tmp_array==fillvalue$value] <- NA
length(na.omit(as.vector(tmp_array[,,1])))

# get a single slice or layer (January)
m <- 1
tmp_slice <- tmp_array[,,m]

# create dataframe -- reshape data
# matrix (nlon*nlat rows by 2 cols) of lons and lats
lonlat <- as.matrix(expand.grid(lon,lat))
dim(lonlat)

# vector of `tmp` values
tmp_vec <- as.vector(tmp_slice)
length(tmp_vec)

# create dataframe and add names
tmp_df01 <- data.frame(cbind(lonlat,tmp_vec))
names(tmp_df01) <- c("lon","lat",paste(dname,as.character(m), sep="_"))
head(na.omit(tmp_df01), 10)

# set path and filename
csvname <- "cru_tmp_1.csv"
csvfile <- paste(csvpath, csvname, sep="")
write.table(na.omit(tmp_df01),csvfile, row.names=FALSE, sep=",")


# reshape the vector into a matrix
tmp_mat <- matrix(tmp_vec, nrow=nlon*nlat, ncol=nt)
dim(tmp_mat)

# reshape the array into vector
tmp_vec_long <- as.vector(tmp_array)
length(tmp_vec_long)

# reshape the vector into a matrix
tmp_mat <- matrix(tmp_vec_long, nrow=nlon*nlat, ncol=nt)
dim(tmp_mat)


# create a dataframe
lonlat <- as.matrix(expand.grid(lon,lat))
tmp_df02 <- data.frame(cbind(lonlat,tmp_mat))
names(tmp_df02) <- c("lon","lat","tmpJan","tmpFeb","tmpMar","tmpApr","tmpMay","tmpJun",
  "tmpJul","tmpAug","tmpSep","tmpOct","tmpNov","tmpDec")
# options(width=96)
head(na.omit(tmp_df02, 20))

# set path and filename
csvname <- "cru_tmp_2.csv"
csvfile <- paste(csvpath, csvname, sep="")
write.table(na.omit(tmp_df02),csvfile, row.names=FALSE, sep=",") 


