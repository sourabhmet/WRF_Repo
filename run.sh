cd /home/sourabh/Build_WRF/data
rm gfs.t*
Tdate=$(date +"%Y%m%d" --date="1 day ago")
for time in 00;do ##00 06 12 18
for fcst in {000..072..6};do

#wget ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${year}${month}${day}/${time}/gfs.t${time}z.pgrb2.0p25.f${fcst} .  ##0.25 degree
#wget ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${year}${month}${day}/${time}/gfs.t${time}z.pgrb2.0p50.f${fcst} . ##0.5 Degree
wget ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${Tdate}/${time}/gfs.t${time}z.pgrb2.1p00.f${fcst} . ## 1 degree
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
sdate=$(date +"%Y-%m-%d" --date="1 day ago")
edate=$(date +"%Y-%m-%d" --date="2 day ")
hrs1=06
hrs2=00
#######
cat <<EOF> namelist.ARWpost
&datetime
start_date = '${sdate}_${hrs1}:00:00',
end_date   = '${edate}_${hrs2}:00:00',
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
#########NCL Script
sdate=$(date +"%Y-%m-%d" --date="1 day ago")
edate1=$(date +"%Y-%m-%d")
edate2=$(date +"%Y-%m-%d" --date="1 day ")
edate3=$(date +"%Y-%m-%d" --date="2 day ")
hrs1=06
hrs2=00
##############
##############NCL Script
cat << EOF > plot.ncl
begin
;---Open WRF output file.
 dir      = "./"
 filename1 = "wrfout_d01_${sdate}_${hrs1}:00:00"
 filename2 = "wrfout_d01_${edate1}_${hrs2}:00:00"
 filename3 = "wrfout_d01_${edate2}_${hrs2}:00:00"
 filename4 = "wrfout_d01_${edate3}_${hrs2}:00:00"
 a = addfile(dir + filename1 + ".nc","r")
 b = addfile(dir + filename2 + ".nc","r")
 c = addfile(dir + filename3 + ".nc","r")
 d = addfile(dir + filename4 + ".nc","r")
 
 ;---Read terrain height and lat/lon off file.
 it        = 0     ; first time step
 rainc1       = wrf_user_getvar(a,"RAINC",it)    ; Terrain elevation
 rainnc1       = wrf_user_getvar(a,"RAINNC",it)    ; Terrain elevation
 out1 = rainc1+rainnc1
 rainnc1@lat2d = wrf_user_getvar(a,"XLAT",it)   ; latitude/longitude
 rainnc1@lon2d = wrf_user_getvar(a,"XLONG",it)  ; required for plotting
 rainc2       = wrf_user_getvar(b,"RAINC",it)    ; Terrain elevation
 rainnc2       = wrf_user_getvar(b,"RAINNC",it)    ; Terrain elevation
 out2 = rainc2+rainnc2
 rainca2 = out2-out1
 rainca2@lat2d = wrf_user_getvar(b,"XLAT",it)   ; latitude/longitude
 rainca2@lon2d = wrf_user_getvar(b,"XLONG",it)  ; required for plotting
 rainc3       = wrf_user_getvar(c,"RAINC",it)    ; Terrain elevation
 rainnc3       = wrf_user_getvar(c,"RAINNC",it)    ; Terrain elevation
 out3 = rainc3+rainnc3
 rainca3 = out3-out2
 rainca3@lat2d = wrf_user_getvar(c,"XLAT",it)   ; latitude/longitude
 rainca3@lon2d = wrf_user_getvar(c,"XLONG",it)  ; required for plotting
 rainc4       = wrf_user_getvar(d,"RAINC",it)    ; Terrain elevation
 rainnc4       = wrf_user_getvar(d,"RAINNC",it)    ; Terrain elevation
 out4 = rainc4+rainnc4
 rainca4 = out4-out3
 rainca4@lat2d = wrf_user_getvar(d,"XLAT",it)   ; latitude/longitude
 rainca4@lon2d = wrf_user_getvar(d,"XLONG",it)  ; required for plotting
 ; 
 wks = gsn_open_wks("png","${sdate}")
 plots     = new(4,graphic)
 gsn_define_colormap(wks,"WhViBlGrYeOrRe")

 ;---Set some basic plot options
 res               = True
 res@gsnMaximize           = False              ; enlarge plot
 res@gsnDraw               = False             ; Don't draw yet
 res@gsnFrame              = False             ; Don't advance frame yet
 ;  res@tiMainString  = "00:00 14-Jul-2020 forecast for next 6 Hours" 
 res@cnFillOn      = True  
 res@cnFillPalette = "WhViBlGrYeOrRe"
 res@cnLinesOn     = False
 res@gsnLeftString = "" 

 res@mpProjection  = "CylindricalEquidistant"    ; The default
 res@mpDataBaseVersion = "MediumRes"

 res@gsnAddCyclic      = False
 res@lbLabelBarOn         = False                  ; turn off labelbar
 res@cnLevelSelectionMode = "ManualLevels"      ; set manual contour levels
 res@cnMinLevelValF       =  1                ; set min contour level
 res@cnMaxLevelValF       =  100.                ; set max contour level
 res@cnLevelSpacingF      =  10                ; set contour spacing

 ;---Zoom in on plot

 res@mpMinLatF     = min(rainnc1@lat2d)

 res@mpMaxLatF     = max(rainnc1@lat2d)

 res@mpMinLonF     = min(rainnc1@lon2d)

 res@mpMaxLonF     = max(rainnc1@lon2d)

 res@txFontHeightF = 0.014          ; fontsize of the subtitles

 ;  res@tiMainString  = "00:00 14-Jul-2020 forecast for next 6 Hours" 

 res@gsnLeftString ="(a) 06 Hour Forecast Valid on ${sdate}:${hrs1}:00" 
 plots(0) = gsn_csm_contour_map(wks,rainnc1,res)

 res@gsnLeftString ="(b) 24 Hour Forecast Valid on ${edate1}:${hrs2}:00" 
 plots(1) = gsn_csm_contour_map(wks,rainca2,res)

 res@gsnLeftString ="(c) 48 Hour Forecast Valid on ${edate2}:${hrs2}:00" 
 plots(2) = gsn_csm_contour_map(wks,rainca3,res)

 res@gsnLeftString ="(c) 72 Hour Forecast Valid on ${edate3}:${hrs2}:00" 
 plots(3) = gsn_csm_contour_map(wks,rainca4,res)

 ;;;

 pres = True
 pres@gsnFrame = True 
 pres@gsnPanelYWhiteSpacePercent = 1
 pres@gsnPanelLabelBar    = True                ; add common colorbar
 pres@lbLabelFontHeightF  = 0.012               ; make labels smaller
 gsn_panel(wks,plots,(/2,2/),pres)
 ;  draw(plots)
 ;  frame(wks)   ; now advance the frame!
end
EOF
ncl plot.ncl
mv ${sdate}.png plots/
sudo rm /var/www/html/wrf_gsn.png
sudo cp plots/${sdate}.png /var/www/html/wrf_gsn.png
