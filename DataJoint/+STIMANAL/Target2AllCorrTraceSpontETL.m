%{
# Pairwise correlation between the activity of a target neuron and each of the rest of the neurons
-> EXP2.SessionEpoch
-> IMG.PhotostimGroup
threshold_for_event             : double  # threshold in deltaf_overf
num_svd_components_removed_corr : int     # how many of the first svd components were removed for computing correlations
---
rois_corr                        :blob    # correlation between the activity of the target neuron an each of the ROI, including self
%}


classdef Target2AllCorrTraceSpontETL < dj.Computed
     properties
        keySource = (EXP2.SessionEpoch& 'session_epoch_type="spont_photo"') & STIM.ROIInfluence5ETL & (EXP2.Session & (EXP2.SessionEpoch & 'session_epoch_type="spont_only"')  & (EXP2.SessionEpoch & 'session_epoch_type="spont_photo"'));
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            rel_roi = (IMG.ROI - IMG.ROIBad) & key;
            
            time_bin=1.5; %s
            threshold_for_event_vector = [0];
            num_svd_components_removed_vector = [0,1,2,3,4,5,10];
            
            keytemp = rmfield(key,'session_epoch_number');
            keytemp.session_epoch_type='spont_only';
            key_spont = fetch(EXP2.SessionEpoch & keytemp,'LIMIT 1');
            
            try
                imaging_frame_rate= fetch1(IMG.FOVEpoch & key_spont, 'imaging_frame_rate');
            catch
                imaging_frame_rate = fetch1(IMG.FOV & key_spont, 'imaging_frame_rate');
            end
            
            %% Loading Data
            rel_data = IMG.ROISpikes & rel_roi;
            rel_photostim =IMG.PhotostimGroup*(STIM.ROIResponseDirect5ETL) & key;
            rel_photostim=rel_photostim;
            group_list = fetchn(rel_photostim,'photostim_group_num','ORDER BY photostim_group_num');
            target_roi_list = fetchn(rel_photostim,'roi_number','ORDER BY photostim_group_num');
            
            roi_list=fetchn(rel_data &key_spont,'roi_number','ORDER BY roi_number');
            chunk_size=500;
            counter=0;
            for i_chunk=1:chunk_size:roi_list(end)
                roi_interval = [i_chunk, i_chunk+chunk_size];
                temp_F=cell2mat(fetchn(rel_data & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'spikes_trace','ORDER BY roi_number'));
                temp_count=(counter+1):1: (counter + size(temp_F,1));
                Fall(temp_count,:)=temp_F;
                counter = counter + size(temp_F,1);
            end
            
            
            %% binning in time
            bin_size_in_frame=ceil(time_bin*imaging_frame_rate);
            
            bins_vector=1:bin_size_in_frame:size(Fall,2);
            bins_vector=bins_vector(2:1:end);
            for  i= 1:1:numel(bins_vector)
                ix1=(bins_vector(i)-bin_size_in_frame):1:(bins_vector(i)-1);
                F(:,i)=mean(Fall(:,ix1),2);
            end
            clear Fall temp_Fall
            
            
            %% Thresholding activity and computing SVD and correlations
            for i_th = 1:1:numel(threshold_for_event_vector)
                threshold= threshold_for_event_vector(i_th);
                
                for i_c = 1:1:numel(num_svd_components_removed_vector)
                    F_thresholded=F;
                    if threshold>0
                        F_thresholded(F<=threshold)=0;
                    end
                    %                     F_thresholded = F_thresholded(idx_enough_events,:);
                    rho=[];
                    F_thresholded = gpuArray((F_thresholded));
                    if num_svd_components_removed_vector(i_c)>0
                        num_comp = num_svd_components_removed_vector(i_c);
                        %                         F_thresholded = F_thresholded-mean(F_thresholded,2);
                        F_thresholded=zscore(F_thresholded,[],2);
                        
                        [U,S,V]=svd(F_thresholded); % S time X neurons; % U time X time;  V neurons x neurons
                        
                        singular_values =diag(S);
                        
                        variance_explained=singular_values.^2/sum(singular_values.^2); % a feature of SVD. proportion of variance explained by each component
                        %                         cumulative_variance_explained=cumsum(variance_explained);
                        
                        U=U(:,(1+num_comp):end);
                        %             S=S(1:num_comp,1:num_comp);
                        V=V(:,(1+num_comp):end);
                        S = S((1+num_comp):end, (1+num_comp):end);
                        
                        F_reconstruct = U*S*V';
                        clear U S V F_thresholded
                        
                        rho=corrcoef(F_reconstruct');
                        rho=gather(rho);
                    else
                        rho=corrcoef(F_thresholded');
                    end
                    
                    rho=gather(rho);
                    
                    key.threshold_for_event = threshold;
                    key.num_svd_components_removed_corr = num_svd_components_removed_vector(i_c);
                    k_insert = repmat(key,numel(group_list),1);
                    
                    parfor i_g = 1:1:numel(group_list)
                        target_roi_idx = (roi_list == target_roi_list(i_g));
                        k_insert(i_g).photostim_group_num = group_list(i_g);
                        corr_with_target= rho(target_roi_idx,:);
                        corr_with_target(target_roi_idx)=NaN; %setting self correlation to NaN
                        k_insert(i_g).rois_corr =corr_with_target;
                    end
                    insert(self,k_insert);
                    clear rho
                end
            end
        end
    end
end

