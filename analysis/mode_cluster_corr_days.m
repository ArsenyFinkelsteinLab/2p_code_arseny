function mode_cluster_corr_days()
close all;
anm=437545;

dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\ProjLongitudinal_cluster_weightscorr\AF09_anm437545\'];

first_date{1}='2019_01_18';
first_date{2}='2019_02_04';

key.subject_id=anm;
for i = 1:1:numel(first_date)
    fn_mode_cluster_corr_days(key, first_date{i}, dir_save_figure)
end


% populate_imaging_psth_across_days();

