function selectivity_across_days()


dir_data = 'Z:\users\Arseny\Projects\Learning\imaging2p\RawData\AF09_anm437545\SI\';
anm=437545;

% date{1}='2019_01_18';
% date{end+1}='2019_01_19';
% date{end+1}='2019_01_20';
% date{end+1}='2019_01_21';
% date{end+1}='2019_01_22';
% date{end+1}='2019_01_23';
% date{end+1}='2019_01_24';
% date{1}='2019_02_04';
date{1}='2019_02_05';


figure;

for i=1:1:numel(date)
key.subject_id=anm;
key.session_date=date{i};

selectivity_maps_temp(key)

end




