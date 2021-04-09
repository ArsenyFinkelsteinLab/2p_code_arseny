function selectivity_maps_temp(key)
dir_data = 'Z:\users\Arseny\Projects\Learning\imaging2p\RawData\AF09_anm437545\SI\';

dir_save_figure='Z:\users\Arseny\Projects\Learning\imaging2p\Results\Selectivity_maps\AF09_anm437545\'

dir_data=[dir_data  key.session_date '\'];
%% Insert/Populate Sessions and dependent tables
allFiles = dir(dir_data); %gets  the names of all files and nested directories in this folder
allFileNames = {allFiles(~[allFiles.isdir]).name}; %gets only the names of all files

allFileNames =allFileNames(contains(allFileNames,'.tif'));

for ifile=1:numel(allFileNames)

    [header,Aout]=scanimage.util.opentif([dir_data,allFileNames{ifile}]);
    Aout=squeeze(Aout);
    img_avg(ifile,:,:) = mean(Aout(:,:,40:end),3);
    ifile
end

% a=fetch(EXP.SessionID,'*')
b=fetch(EXP.BehaviorTrial&(EXP.Session&key),'*','ORDER BY trial');
b=struct2table(b);
left_hit = find(contains(b.trial_instruction,'left') & contains(b.outcome,'hit'));
right_hit = find(contains(b.trial_instruction,'right') & contains(b.outcome,'hit'));
left_miss = find(contains(b.trial_instruction,'left') & contains(b.outcome,'miss'));
right_miss = find(contains(b.trial_instruction,'right') & contains(b.outcome,'miss'));

% Hit
subplot(3,3,1)
map_2plot=squeeze(mean(img_avg(left_hit,:,:),1));
imagesc(map_2plot);
title('Left, Hit');

subplot(3,3,2)
map_2plot=squeeze(mean(img_avg(right_hit,:,:),1));
imagesc(map_2plot);
title('Right, Hit');

subplot(3,3,3)
selectivity_hit=squeeze(mean(img_avg(right_hit,:,:),1))  -squeeze(mean(img_avg(left_hit,:,:),1));
imagesc(selectivity_hit);
title('Left-Right, Hit');

%Miss
subplot(3,3,4)
map_2plot=squeeze(mean(img_avg(left_miss,:,:),1));
imagesc(map_2plot);
title('Left, Miss');

subplot(3,3,5)
map_2plot=squeeze(mean(img_avg(right_miss,:,:),1));
imagesc(map_2plot);
title('Right, Miss');

subplot(3,3,6)
selectivity_miss=squeeze(mean(img_avg(right_miss,:,:),1))  -squeeze(mean(img_avg(left_miss,:,:),1));
imagesc(selectivity_miss);
title('Left-Right, Miss');


% Hit-Miss
subplot(3,3,7)
map_2plot=squeeze(mean(img_avg(left_hit,:,:),1)) - squeeze(mean(img_avg(left_miss,:,:),1));
imagesc(map_2plot);
title('Left, Hit-Miss');

subplot(3,3,8)
map_2plot=squeeze(mean(img_avg(right_hit,:,:),1)) - squeeze(mean(img_avg(right_miss,:,:),1));
imagesc(map_2plot);
title('Right, Hit-Miss');

subplot(3,3,9)
map_2plot = selectivity_hit- selectivity_miss;
imagesc(map_2plot);
title('Left-Right, Hit-Miss');







if isempty(dir(dir_save_figure))
    mkdir (dir_save_figure)
end

filename=['selectivity_' key.session_date];
figure_name_out=[ dir_save_figure filename];
eval(['print ', figure_name_out, ' -dtiff -cmyk -r600']);
clf;
