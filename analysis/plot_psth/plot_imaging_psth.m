function populate_imaging_psth()
close all;

anm=437545;

date{1}='2019_01_18';
date{end+1}='2019_01_19';
date{end+1}='2019_01_20';
date{end+1}='2019_01_21';
date{end+1}='2019_01_22';
date{end+1}='2019_01_23';
date{end+1}='2019_01_24';
% date{end+1}='2019_02_04';
% date{end+1}='2019_02_05';

for i=1:1:numel(date)
    k.subject_id=anm;
    k.session_date=date{i};
    
    key=fetch(EXP.Session&k);
    fn_populate_imaging_psth(key,k.session_date)
    
end




