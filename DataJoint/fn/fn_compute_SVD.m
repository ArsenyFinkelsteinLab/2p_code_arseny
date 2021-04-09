function fn_compute_SVD(key, rel_data1, self, self2, self3, flag_zscore,time_bin, threshold_for_event_vector, threshold_variance_explained, num_components_save)

key.time_bin = time_bin;
try
    imaging_frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
catch
    imaging_frame_rate = fetch1(IMG.FOV & key, 'imaging_frame_rate');
end

roi_list=fetchn(rel_data1 & key,'roi_number','ORDER BY roi_number');
num_rois=numel(roi_list);
chunk_size=500;
counter=0;
for i_chunk=1:chunk_size:roi_list(end)
    roi_interval = [i_chunk, i_chunk+chunk_size];
    try
        temp_F=cell2mat(fetchn(rel_data1 & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
    catch
        temp_F=cell2mat(fetchn(rel_data1 & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'spikes_trace','ORDER BY roi_number'));
    end
    temp_count=(counter+1):1: (counter + size(temp_F,1));
    F(temp_count,:)=temp_F;
    counter = counter + size(temp_F,1);
end

%% binning in time
if time_bin>0
    bin_size_in_frame=ceil(time_bin*imaging_frame_rate);
    
    bins_vector=1:bin_size_in_frame:size(F,2);
    bins_vector=bins_vector(2:1:end);
    for  i= 1:1:numel(bins_vector)
        ix1=(bins_vector(i)-bin_size_in_frame):1:(bins_vector(i)-1);
        F_binned(:,i)=mean(F(:,ix1),2);
    end
else
    F_binned=F;
end

F_binned = gpuArray(F_binned);
for i_th = 1:1:numel(threshold_for_event_vector)
    threshold= threshold_for_event_vector(i_th);
    key.threshold_for_event = threshold;
    
    F_thresholded=F_binned;
    if threshold>0
        F_thresholded(zscore(F_binned,[],2)<=threshold)=0;
    end
    
    if flag_zscore==0 %only centering the data
        F_thresholded = F_thresholded-mean(F_thresholded,2);
    else % zscoring the data
        F_thresholded=zscore(F_thresholded,[],2);
    end
    
    [U,S,V]=svd(F_thresholded); % S time X neurons; % U time X time;  V neurons x neurons
    S= gather(S);
    
    singular_values =diag(S);
    variance_explained=singular_values.^2/sum(singular_values.^2); % a feature of SVD. proportion of variance explained by each component
    cumulative_variance_explained=cumsum(variance_explained);
    %             plot(cumulative_variance_explained);
    %             xlabel('Component')
    %             ylabel('Cumulative explained variance');
    
    % Dimensionality reduction - taking only the first num_comp that explain variance above threshold_variance_explained. We will then save only num_components_save
    num_comp = find(cumulative_variance_explained>threshold_variance_explained,1,'first');
    U=U(:,1:num_comp);
    % S=S(1:num_comp,1:num_comp);
    VT=V(:,1:num_components_save)';
    clear V;
    
    U =gather(U);
    VT= gather(VT);
    
    
    %% Populating POP.ROISVD
    key_ROIs= fetch(rel_data1 & key, 'ORDER BY roi_number');
    parfor i=1:1:size(key_ROIs,1)
        key_ROIs(i).roi_components = U(i,:);
        key_ROIs(i).time_bin = time_bin;
        key_ROIs(i).threshold_for_event = threshold_for_event_vector(i_th);
    end
    
    chunk_size=1000;
    for i_chunk=1:chunk_size:num_rois
        idx =i_chunk:1:(i_chunk+chunk_size-1);
        if idx(end)>num_rois
            idx=idx(1):1:num_rois;
        end
        insert(self,key_ROIs(idx));
    end
    
    
    %% Populating POP.SVDSingularValues
    key_singular_values=key;
    key_singular_values.singular_values= singular_values;
    insert(self2,key_singular_values);
    
    
    %% Populating POP.SVDTemporalComponents
    key_temporal= repmat(key,1,num_components_save);
    parfor ic = 1:1:num_components_save
        key_temporal(ic).component_id=ic;
        key_temporal(ic).temporal_component=VT(ic,:);
    end
    insert(self3,key_temporal);
    
end