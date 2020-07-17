cd /home/sourabh/Build_WRF/data
rm gfs.t*
year=2020
month=07
day=14
for time in 06;do ##00 06 12 18
for fcst in {000..072..6};do

#wget ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${year}${month}${day}/${time}/gfs.t${time}z.pgrb2.0p25.f${fcst} .  ##0.25 degree
#wget ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${year}${month}${day}/${time}/gfs.t${time}z.pgrb2.0p50.f${fcst} . ##0.5 Degree
wget ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${year}${month}${day}/${time}/gfs.t${time}z.pgrb2.1p00.f${fcst} . ## 1 degree
done
done
cd -
sh namlist.sh
####WPS
mv namelist.wps /home/sourabh/Build_WRF/WPS/ 
cd /home/sourabh/Build_WRF/WPS/
rm GRIBFILE* met_em.d01* geo_em.d01.nc
rm FILE*
mpirun -np 1 /home/sourabh/Build_WRF/WPS/geogrid.exe

./link_grib.csh /home/sourabh/Build_WRF/data/gfs.* .  ###link  DAta path
mpirun -np 1 ./ungrib.exe
mpirun -np 2 ./metgrid.exe
#mv met_em.d01.*.nc FILE* geo_em.d*.nc /home/sourabh/Build_WRF/run
cd -

###WRF
mv namelist.input /home/sourabh/Build_WRF/WRFV3/test/em_real/
cd /home/sourabh/Build_WRF/WRFV3/test/em_real/
rm met_em.d01* wrfbdy_d01 wrfinput_d01 rsl*
#year=2020
#mon=07
#date=14
#for tt in 06;do
#ln -fs /home/sourabh/Build_WRF/WPS/met_em.d01.${year}-${mon}-${date}_${tt}:00:00.nc .  ###link met files
#done
ln -fs /home/sourabh/Build_WRF/WPS/met_em.d01* .  ###link met files

mpirun -np 4 ./real.exe
mpirun -np 8 ./wrf.exe
cd -

rm wrfout_*
mv /home/sourabh/Build_WRF/WRFV3/test/em_real/wrfout_* .

##ARWPost
year=2020
mon=07
sdate=14
edate=17
hrs1=06
hrs2=00
#######
cat <<EOF> namelist.ARWpost
&datetime
start_date = '${year}-${mon}-${sdate}_${hrs1}:00:00',
end_date   = '${year}-${mon}-${edate}_${hrs2}:00:00',
interval_seconds = 21600,
tacc = 0,
debug_level = 0,
/

&io
input_root_name = '/home/sourabh/Build_WRF/run/wrfout_d01*'
output_root_name = '/home/sourabh/Build_WRF/run/out'
plot = 'all_list'
fields = 'height,pressure,tk,tc'
mercator_defs = .true.
/

split_output = .true.
frames_per_outfile = 2

plot = 'all'
plot = 'list' 
plot = 'all_list'
! Below is a list of all available diagnostics
fields = 'height,geopt,theta,tc,tk,td,td2,rh,rh2,umet,vmet,pressure,u10m,v10m,wdir,wspd,wd10,ws10,slp,mcape,mcin,lcl,lfc,cape,cin,dbz,max_dbz,clfr'


&interp
interp_method = 0,
interp_levels = 1000.,950.,900.,850.,800.,750.,700.,650.,600.,550.,500.,450.,400.,350.,300.,250.,200.,150.,100.,
/
extrapolate = .true.
interp_method = 0,     
! 0 is model levels, -1 is nice height levels, 1 is user specified pressure/height
interp_levels = 1000.,950.,900.,850.,800.,750.,700.,650.,600.,550.,500.,450.,400.,350.,300.,250.,200.,150.,100.,
interp_levels = 0.25, 0.50, 0.75, 1.00, 2.00, 3.00, 4.00, 5.00, 6.00, 7.00, 8.00, 9.00, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0,
EOF

mv namelist.ARWpost /home/sourabh/Build_WRF/ARWpost/
cd /home/sourabh/Build_WRF/ARWpost
./ARWpost.exe
cd -
