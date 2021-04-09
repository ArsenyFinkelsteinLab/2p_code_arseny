function pv_corr_all_sessions_Xweights()
close all;
anm=437545;

dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_all_sessions_intersect_xWeights_abs\AF09_anm437545\'];
rel=ANLI.IncludeROImultiSession2intersect;

% dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_all_sessions_union_xWeights\AF09_anm437545\'];
% rel=ANLI.IncludeROImultiSession2union;


first_date{1}='2019_01_18';
first_date{2}='2019_02_04';
key.subject_id=anm;

mode_names= {'LateDelay','Movement','Ramping'};

for i=1:1:numel(first_date)
    for i_m=1:1:numel(mode_names)

    fn_pv_corr_all_sessions_xWeights(key, first_date{i}, dir_save_figure, rel, mode_names{i_m})
    end
end





