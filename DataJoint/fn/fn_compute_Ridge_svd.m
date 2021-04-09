function fn_compute_Ridge_svd(key,self,self2, rel_data1,rel_data2,rel_data3,time_shift_vec)
rel_predictor_type = (RIDGE.PredictorType&RIDGE.PredictorTypeUse);

key_ROI1=fetch(rel_data1 & key,'ORDER BY roi_number'); %
key_ROI2=key_ROI1; % for variance

U=cell2mat(fetchn(rel_data1 & key,'roi_components','ORDER BY roi_number'));
S=fetch1(rel_data2 & key,'singular_values')';
VT=cell2mat(fetchn(rel_data3 & key,'temporal_component','ORDER BY component_id'));

num_comp = size(VT,1);
VT = VT.*S(1:num_comp)';
VT=VT';


rel_start_frame = IMG.FrameStartTrial  & key & RIDGE.Predictors;
TrialsStartFrame=fetchn(rel_start_frame,'session_epoch_trial_start_frame','ORDER BY trial');
trial_num=fetchn(rel_start_frame, 'trial','ORDER BY trial');

if isempty(TrialsStartFrame) % not mesoscope recordings
    rel_start_frame = IMG.FrameStartFile  & key & RIDGE.Predictors;
    TrialsStartFrame=fetchn(rel_start_frame,'session_epoch_file_start_frame','ORDER BY trial');
    trial_num=fetchn(rel_start_frame,'trial','ORDER BY trial');
end



P=struct2table(fetch(RIDGE.Predictors*rel_predictor_type & key,'*','ORDER BY trial'));

idx_frames=[];
for i_tr = 1:1:numel(trial_num)
    idx=find(P.trial==trial_num(i_tr),1,'first');
    TrialsEndFrame = TrialsStartFrame(i_tr) + numel(P.trial_predictor{idx}) - TrialsStartFrame(1);
    idx_frames = [idx_frames, (TrialsStartFrame(i_tr)- TrialsStartFrame(1)+1):1:TrialsEndFrame];
end

predictor_name = fetchn(rel_predictor_type,'predictor_name', 'ORDER BY predictor_name');
predictor_category = fetchn(rel_predictor_type,'predictor_category', 'ORDER BY predictor_name');

for i_p = 1:1:numel(predictor_name)
    idx = strcmp(P.predictor_name,predictor_name{i_p});
    temp  = cell2mat(P.trial_predictor(idx)');
    temp(isnan(temp)) = nanmedian(temp);
    predictor=temp;
    if strcmp(predictor_category{i_p},'move')
        if strcmp(predictor_name{i_p},'PawFrontLeft')
            predictor=predictor<nanmean(predictor);
        else
            predictor=predictor>nanmean(predictor);
        end
    elseif strcmp(predictor_category{i_p},'lick')
        predictor=predictor>=1;
    end
    predictor_mat(:,i_p) = predictor;
    %     %% for debug
    %     clf
    %     hold on;
    %     plot(temp)
    %     plot(predictor+mean(temp));
    %     title(predictor_name{i_p})
end

% idx_frames
% [predictor_vector,idx_frames] = fn_compute_ridge_predictors (key, frame_rate);



predictor_mat_full=[];

for it=1:1:numel(time_shift_vec)
    shift=(time_shift_vec(it));
    PM=zeros(size(predictor_mat));
    if shift<=0
        PM (1:end+shift,:) = predictor_mat(abs(shift)+1:end,:);
    elseif shift>0
        PM (1+shift:end,:) = predictor_mat(1:end-shift,:);
    end
    predictor_mat_full=[predictor_mat_full,PM];
end





%% Ridge regression
VT=VT(idx_frames,:);
[~, dimBeta] = ridgeMML(VT, predictor_mat_full, true); %get ridge penalties and beta weights.

VTr = predictor_mat_full*dimBeta; %temporal components in time reconstructed based on the ridge model
variance_explained =fn_compute_Ridge_svd_variance_explained(VT,VTr,U);

%% variance of each ROI activity explained by the ridge model
for i_roi=1:1:numel(key_ROI1)
    key_ROI2(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI2(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI2(i_roi).variance_explained=variance_explained(i_roi);
end
insert(self2,key_ROI2);

%% regression coefficient of each predictor for each ROI
X=U*dimBeta';
num_of_predict = numel(predictor_name);
for it=1:1:numel(time_shift_vec)
    parfor i_p = 1:1:num_of_predict
        fn_insert_ridge_dj(self,key,key_ROI1,predictor_name,i_p,X,it,num_of_predict,time_shift_vec);
    end
end


end


