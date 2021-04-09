function pv_corr()
close all;
anm=437545;

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

flag_signif=4;
dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_signif_ROIs2_2bin\AF09_anm437545\'];
clustering_option_name = 'signif single session selective delay response'; 

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

key.subject_id=anm;

k.clustering_option_name=clustering_option_name;
del(ANLI.TrialCluster & k);

for i=1:1:numel(date)
    close all;
    fn_pv_corr_2bin(key, date{i}, dir_save_figure, flag_signif, clustering_option_name)
end





