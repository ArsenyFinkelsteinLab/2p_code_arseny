function populate_imaging_roi_across_days()

anm=437545;

dir_data_combined = 'Z:\users\Arseny\Projects\Learning\imaging2p\Registered\AF09_anm437545\suite2p\2019_01_18_24\';
dates{1}='2019_01_18';
dates{end+1}='2019_01_19';
dates{end+1}='2019_01_20';
dates{end+1}='2019_01_21';
dates{end+1}='2019_01_22';
dates{end+1}='2019_01_23';
dates{end+1}='2019_01_24';

% dir_data_combined = 'Z:\users\Arseny\Projects\Learning\imaging2p\Registered\AF09_anm437545\suite2p\2019_02_04_08\';
% dates{1}='2019_02_04';
% dates{end+1}='2019_02_05';
% dates{end+1}='2019_02_06';
% dates{end+1}='2019_02_07';
% dates{end+1}='2019_02_08';


key.subject_id=anm;
fn_populate_ROI_across_days(key, dates, dir_data_combined)



% populate_imaging_psth_across_days();

