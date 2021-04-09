function pv_corr_all_sessions()
close all;
anm=437545;

dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_all_sessions_intersect_test\AF09_anm437545\'];
rel=ANLI.IncludeROImultiSession2intersect;

dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_all_sessions_union_test\AF09_anm437545\'];
rel=ANLI.IncludeROImultiSession2union;


first_date{1}='2019_01_18';
first_date{2}='2019_02_04';
key.subject_id=anm;

for i=1:1:numel(first_date)
    fn_pv_corr_all_sessions(key, first_date{i}, dir_save_figure, rel)

end





