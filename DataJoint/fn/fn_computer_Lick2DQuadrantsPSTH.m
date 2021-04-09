function fn_computer_Lick2DQuadrantsPSTH(key,self, rel_data, fr_interval,dir_current_fig)

smooth_window_sec=0.2; %frames for PSTH
radius_threshold = 0.1;



rel_ROI = (IMG.ROI-IMG.ROIBad) & key;
key_ROI1=fetch(rel_ROI,'ORDER BY roi_number'); % LICK2D.ROILick2DPSTH

rel_data =rel_data & rel_ROI & key;

session_date = fetch1(EXP2.Session & key,'session_date');


try
    frame_rate = fetch1(IMG.FOVEpoch & key,'imaging_frame_rate');
catch
    frame_rate = fetch1(IMG.FOV & key,'imaging_frame_rate');
end

smooth_window_frames = ceil(smooth_window_sec*frame_rate); %frames for PSTH

S=fetch(rel_data,'*');
if isfield(S,'spikes_trace') % to be able to run the code both on dff and on deconvulted "spikes" data
    [S.dff_trace] = S.spikes_trace;
    S = rmfield(S,'spikes_trace');
end

[start_file, end_file ] = fn_parse_into_trials (key, frame_rate, fr_interval);
num_trials =numel(start_file);

idx_response = (~isnan(start_file));
% idx odd/even
idx_odd = ismember(1:1:num_trials,1:2:num_trials) & idx_response;
idx_even =  ismember(1:1:num_trials,2:2:num_trials) & idx_response;


[POS] = fn_rescale_and_rotate_lickport_pos (key);
pos_x = POS.pos_x;
pos_z = POS.pos_z;


[theta, radius] = cart2pol(pos_x,pos_z);
theta=rad2deg(theta);

%Dividing of the data based on quadrants of the tongue-directin response
idx_Q{1}=(theta>-15 & theta<90 & radius>radius_threshold); % radius threshold ensured that we don't take the central bin in case of a 3x3 arrangment
idx_Q{2}=(theta>=90 & theta<180 & radius>radius_threshold);
idx_Q{3}=((theta>=-180 & theta<-90) | theta==180) & radius>radius_threshold;
idx_Q{4}=(theta>=-90 & theta<=-15 & radius>radius_threshold);

%% for DEBUG
hold on
plot(pos_x+rand(1,numel(pos_x))/10, pos_z+rand(1,numel(pos_x))/10,'.')
% we assign more trials to the two bottom quadrants, becuase the behavioral coverage is often poorer in bottom quandrants
plot(pos_x(idx_Q{1}),pos_z(idx_Q{1}),'or')
plot(pos_x(idx_Q{2}),pos_z(idx_Q{2}),'og')
plot(pos_x(idx_Q{3}),pos_z(idx_Q{3}),'ob')
plot(pos_x(idx_Q{4}),pos_z(idx_Q{4}),'om')
title(sprintf('anm%d %s session %d',key.subject_id, session_date, key.session),'FontSize',10);


for i_roi=1:1:size(S,1)
    
    key_ROI1(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI1(i_roi).session_epoch_number = key.session_epoch_number;
    
    key_ROI2(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI2(i_roi).session_epoch_number = key.session_epoch_number;
    
    
    %% PSTH
    spikes=S(i_roi).dff_trace;
    for i_tr = 1:1:numel(start_file)
        if idx_response(i_tr)==0 %its an ignore trial
            psth_all{i_tr}=NaN;
            continue
        end
        s=spikes(start_file(i_tr):end_file(i_tr));
        s=movmean(s,[smooth_window_frames 0],'omitnan','Endpoints','shrink');
        time=(1:1:numel(s))/frame_rate + fr_interval(1);
        %         s_interval=s(time>fr_interval(1) & time<=fr_interval(2));
        %         fr_all(i_roi,i_tr)= max(s_interval); %taking the max
        psth_all{i_tr}=s;
    end
    
    psth=[];
    psth_stem=[];
    psth_odd=[];
    psth_even=[];
    
    % Contactenated PSTH for the 4 different quadrants
    for i_q = 1:1:numel(idx_Q)
        current_idx = idx_response & idx_Q{i_q};
        psth = [psth, mean(cell2mat(psth_all(current_idx)'),1)];
        psth_stem = [psth_stem, std(cell2mat(psth_all(current_idx)'),1)/sqrt(sum(current_idx))];
        
        psth_odd = [psth_odd, mean(cell2mat(psth_all(current_idx & idx_odd)'),1)];
        psth_even = [psth_even, mean(cell2mat(psth_all(current_idx & idx_even)'),1)];
        
    end
    
    
    
    key_ROI1(i_roi).psth_quadrants = psth;
    key_ROI1(i_roi).psth_quadrants_stem = psth_stem;
    key_ROI1(i_roi).psth_quadrants_odd = psth_odd;
    key_ROI1(i_roi).psth_quadrants_even = psth_even;
    key_ROI1(i_roi).psth_quadrants_time = time;
    
    r = corr([psth_odd(:),psth_even(:)],'Rows' ,'pairwise');
    key_ROI1(i_roi).psth_quadrants_odd_even_corr = r(2);
    
    
    k2=key_ROI1(i_roi);
    insert(self, k2);
    
    %     clf
    %     hold on; plot(time,nanmean(cell2mat(psth_all(idx_response & idx_Q{1})'),1))
    %     hold on; plot(time,nanmean(cell2mat(psth_all(idx_response & idx_Q{2})'),1))
    %     hold on; plot(time,nanmean(cell2mat(psth_all(idx_response & idx_Q{3})'),1))
    %     hold on; plot(time,nanmean(cell2mat(psth_all(idx_response & idx_Q{4})'),1))
    %     title(sprintf('ROI = %d     r [odd,even]=%.2f',key_ROI1(i_roi).roi_number,r(2)))
    
end



if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
filename=[num2str(key.subject_id) '_s' num2str( key.session) '_'  num2str(session_date) '_quadrants' ];
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r100']);
clf
% eval(['print ', figure_name_out, ' -dpdf -r200']);

