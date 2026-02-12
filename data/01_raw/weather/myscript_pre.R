


# Load the ncdf4 package
if (!require(ncdf4)) {
  install.packages("ncdf4")
  library(ncdf4)
}

# Set the path to the directory
ncpath = "C:/Users/user/Documents/Manu Scripts/Wisdom Proposal/Weather Data/"


# Ensure the directory exists
if (dir.exists(ncpath)) {
  print("The directory exists.")
} else {
  stop("The directory does not exist.")
}

# Set the filename
ncname <- "cru_ts4.07.1901.2022.pre.dat"

ncfname <- paste(ncpath, ncname, ".nc", sep="")

# Print the full path to the netCDF file to check it
print(paste("The full path to the netCDF file is:", ncfname))



# Ensure the file exists
if (file.exists(ncfname)) {
  print("The file exists.")
} else {
  stop("The file does not exist.")
}

# Open the netCDF file
ncin <- nc_open(ncfname)
print("The netCDF file has been opened successfully.")


dname <- "pre"  # note: pre means precipitation (not temporary)
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
pre <- ncvar_get(ncin,"pre")
pre_array <- ncvar_get(ncin,dname)
dlname <- ncatt_get(ncin,dname,"long_name")
dunits <- ncatt_get(ncin,dname,"units")
fillvalue <- ncatt_get(ncin,dname,"_FillValue")
dim(pre_array)
# get global attributes
title <- ncatt_get(ncin,0,"title")
institution <- ncatt_get(ncin,0,"institution")
datasource <- ncatt_get(ncin,0,"source")
references <- ncatt_get(ncin,0,"references")
history <- ncatt_get(ncin,0,"history")
Conventions <- ncatt_get(ncin,0,"Conventions")

nc_close(ncin)

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
pre_array[pre_array==fillvalue$value] <- NA
length(na.omit(as.vector(pre_array[,,1])))

# get a single slice or layer (January)
m <- 1
pre_slice <- pre_array[,,m]

# create dataframe -- reshape data
# matrix (nlon*nlat rows by 2 cols) of lons and lats
lonlat <- as.matrix(expand.grid(lon,lat))
dim(lonlat)

# vector of `pre` values
pre_vec <- as.vector(pre_slice)
length(pre_vec)

# create dataframe and add names
pre_df01 <- data.frame(cbind(lonlat,pre_vec))
names(pre_df01) <- c("lon","lat",paste(dname,as.character(m), sep="_"))
head(na.omit(pre_df01), 10)

# set path and filename
csvpath <-  "C:/Users/user/Documents/Manu Scripts/Wisdom Proposal/Weather Data/"
csvname <- "cru_pre_1.csv"
csvfile <- paste(csvpath, csvname, sep="")
write.table(na.omit(pre_df01),csvfile, row.names=FALSE, sep=",")

# reshape the array into vector
pre_vec_long <- as.vector(pre_array)
length(pre_vec_long)

# reshape the vector into a matrix
pre_mat <- matrix(pre_vec_long, nrow=nlon*nlat, ncol=nt)
dim(pre_mat)


# create a dataframe
lonlat <- as.matrix(expand.grid(lon,lat))
pre_df02 <- data.frame(cbind(lonlat,pre_mat))
names(pre_df02) <- c("lon","lat","preJan","preFeb","preMar","preApr","preMay","preJun",
  "preJul","preAug","preSep","preOct","preNov","preDec")
# options(width=96)
head(na.omit(pre_df02, 20))

# set path and filename
csvpath <-  "C:/Users/user/Documents/Manu Scripts/Wisdom Proposal/Weather Data/"
csvname <- "cru_pre_2.csv"
csvfile <- paste(csvpath, csvname, sep="")
write.table(na.omit(pre_df02),csvfile, row.names=FALSE, sep=",") 


