function pv_corr()
close all;
anm=437545;



date{1}='2019_01_18';
date{end+1}='2019_01_19';
date{end+1}='2019_01_20';
date{end+1}='2019_01_21';
date{end+1}='2019_01_22';
date{end+1}='2019_01_23';
date{end+1}='2019_01_24';
date{end+1}='2019_02_04';
date{end+1}='2019_02_05';
date{end+1}='2019_02_06';
date{end+1}='2019_02_07';
date{end+1}='2019_02_08';


flag_update_cluster_group_table=0;


dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_intersect_test\AF09_anm437545\'];
rel=ANLI.IncludeROImultiSession2intersect;
clustering_option_name = 'deltaf threshold multisession intersect'; 

% dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_union_hitmiss\AF09_anm437545\'];
% rel=ANLI.IncludeROImultiSession2union;
% clustering_option_name = 'deltaf threshold multisession union'; 

key.subject_id=anm;

if flag_update_cluster_group_table~=0
    k.clustering_option_name=clustering_option_name;
    del(ANLI.TrialCluster & k);
end

for i=1:1:numel(date)
    close all;
    fn_pv_corr(key, date{i}, dir_save_figure,  clustering_option_name, rel, flag_update_cluster_group_table)
end




% flag_signif=1;
% dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_signif_ROIs\AF09_anm437545\'];
% 
% flag_signif=0;
% dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr\AF09_anm437545\'];


% flag_signif=2;
% dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_signif_ROIs_ramping\AF09_anm437545\'];

% flag_signif=3;
% dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_signif_ROIs\AF09_anm437545\'];
% clustering_condition_name = 'signif single session';

% flag_signif=3;
% dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_signif_ROIs\AF09_anm437545\'];
% clustering_option_name = 'signif single session'; 

% flag_signif=4;
% dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_signif_ROIs3\AF09_anm437545\'];
% clustering_option_name = 'signif single session selective delay response'; 

% flag_signif=5;
% dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_signif_ROIs4\AF09_anm437545\'];
% clustering_option_name = 'signif single session deltaf'; 
