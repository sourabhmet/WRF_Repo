year=2020
mon=07
sdate=14
edate=17
hrs1=06
hrs2=00
##
dx=13000
dy=13000
#
e_we=100
e_sn=121
#echo $wrf
cat << EOF > namelist.wps 
&share
 wrf_core = 'ARW',
 max_dom = 1,
 start_date = '$year-$mon-${sdate}_$hrs1:00:00',
 end_date   = '$year-$mon-${edate}_$hrs2:00:00',
 interval_seconds = 21600
 io_form_geogrid = 2,
/

&geogrid
 parent_id         =   1,   1,
 parent_grid_ratio =   1,   3,
 i_parent_start    =   1,  31,
 j_parent_start    =   1,  17,
 e_we              =  $e_we, 112,
 e_sn              =  $e_sn,  97,
 ! !!!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT NOTE !!!!!!!!!!!!!!!!!!!!!!!!!!!!
 ! The default datasets used to produce the MAXSNOALB and ALBEDO12M
 ! fields have changed in WPS v4.0. These fields are now interpolated
 ! from MODIS-based datasets.
 !
 ! To match the output given by the default namelist.wps in WPS v3.9.1,
 ! the following setting for geog_data_res may be used:
 !
 ! geog_data_res = 'maxsnowalb_ncep+albedo_ncep+default', 'maxsnowalb_ncep+albedo_ncep+default', 
 !
 !!!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT NOTE !!!!!!!!!!!!!!!!!!!!!!!!!!!!
 !
 geog_data_res = 'default','default',
 dx = $dx,
 dy = $dy,
 map_proj = 'mercator',
 ref_lat   =  39.0,
 ref_lon   =  140.0,
 truelat1  =  39.694,
 truelat2  =  0.0,
 stand_lon =  137.657,
 geog_data_path = '/home/sourabh/Build_WRF/WPS_GEOG/'
/

&ungrib
 out_format = 'WPS',
 prefix = 'FILE',
/

&metgrid
 fg_name = 'FILE'
 io_form_metgrid = 2, 
/
EOF

####namelist.input

cat << EOF> namelist.input
 &time_control
 run_days                            = 3,
 run_hours                           = 00,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = $year, 2000, 2000,
 start_month                         = $mon,   01,   01,
 start_day                           = $sdate,   24,   24,
 start_hour                          = $hrs1,   12,   12,
 start_minute                        = 00,   00,   00,
 start_second                        = 00,   00,   00,
 end_year                            = $year, 2000, 2000,
 end_month                           = $mon,   01,   01,
 end_day                             = $edate,   25,   25,
 end_hour                            = $hrs2,   12,   12,
 end_minute                          = 00,   00,   00,
 end_second                          = 00,   00,   00,
 interval_seconds                    = 21600
 input_from_file                     = .true.,.true.,.true.,
 !!!history interval for output file
 history_interval_m                    = 360,  60,   60,
! frames_per_outfile                  = 1000, 1000, 1000,
 frames_per_outfile                  = 1, 1000, 1000,
 restart                             = .false.,
 restart_interval                    = 5000,
 io_form_history                     = 2
 io_form_restart                     = 2
 io_form_input                       = 2
 io_form_boundary                    = 2
 auxinput1_inname         = "met_em.d<domain>.<date>",
 debug_level                         = 0
 /
 &domains
 time_step                           = 10,
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = 1,
 e_we                                = $e_we,    112,   94,
 e_sn                                = $e_sn,    97,    91,
 e_vert                              = 30,    30,    30,
 p_top_requested                     = 5000,
 num_metgrid_levels                  = 34,
 num_metgrid_soil_levels             = 4, 
 dx                                  = $dx,
 dy                                  = $dy,
 grid_id                             = 1,     2,     3,
 parent_id                           = 0,     1,     2,
 i_parent_start                      = 1,     31,    30,
 j_parent_start                      = 1,     17,    30,
 parent_grid_ratio                   = 1,     3,     3,
 parent_time_step_ratio              = 1,     3,     3,
 feedback                            = 1,
 smooth_option                       = 0
 /

 &physics
 mp_physics                          = 3,     3,     3,
 ra_lw_physics                       = 1,     1,     1,
 ra_sw_physics                       = 1,     1,     1,
 radt                                = 30,    30,    30,
 sf_sfclay_physics                   = 1,     1,     1,
 sf_surface_physics                  = 2,     2,     2,
 bl_pbl_physics                      = 1,     1,     1,
 bldt                                = 0,     0,     0,
 cu_physics                          = 1,     1,     0,
 cudt                                = 5,     5,     5,
 isfflx                              = 1,
 ifsnow                              = 1,
 icloud                              = 1,
 surface_input_source                = 3,
 num_soil_layers                     = 4,
 num_land_cat                        = 21,
 sf_urban_physics                    = 0,     0,     0,
 /

 &fdda
 /
 &dynamics
 w_damping                           = 0,
 diff_opt                            = 1,      1,      1,
 km_opt                              = 4,      4,      4,
 diff_6th_opt                        = 0,      0,      0,
 diff_6th_factor                     = 0.12,   0.12,   0.12,
 base_temp                           = 290.
 damp_opt                            = 0,
 zdamp                               = 5000.,  5000.,  5000.,
 dampcoef                            = 0.2,    0.2,    0.2
 khdif                               = 0,      0,      0,
 kvdif                               = 0,      0,      0,
 non_hydrostatic                     = .true., .true., .true.,
 moist_adv_opt                       = 1,      1,      1,     
 scalar_adv_opt                      = 1,      1,      1,     
 /

 &bdy_control
 spec_bdy_width                      = 5,
 spec_zone                           = 1,

 relax_zone                          = 4,
 specified                           = .true., .false.,.false.,
 nested                              = .false., .true., .true.,
 /

 &grib2
 /

 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /
EOF
###
##ARWPost
cat <<EOF> namelist.ARWpost
&datetime
 start_date = '${year}-${mon}-${sdate}_${hrs1}:00:00',
 end_date   = '${year}-${mon}-${edate}_${hrs2}:00:00',
 interval_seconds = 21600,
 tacc = 0,
 debug_level = 0,
/

&io
 input_root_name = '/home/sourabh/Build_WRF/run/wrfout_d01_*'
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
 interp_method = 0,     ! 0 is model levels, -1 is nice height levels, 1 is user specified pressure/height
 interp_levels = 1000.,950.,900.,850.,800.,750.,700.,650.,600.,550.,500.,450.,400.,350.,300.,250.,200.,150.,100.,
 interp_levels = 0.25, 0.50, 0.75, 1.00, 2.00, 3.00, 4.00, 5.00, 6.00, 7.00, 8.00, 9.00, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0,

EOF
