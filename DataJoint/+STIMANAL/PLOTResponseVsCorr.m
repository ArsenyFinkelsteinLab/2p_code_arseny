%{
# Photostim Group
-> EXP2.SessionEpoch
%}


classdef PLOTResponseVsCorr < dj.Imported
    properties
        keySource = EXP2.SessionEpoch & STIMANAL.ResponseVsCorr;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            clf
            rel_target = IMG.PhotostimGroup & (STIMANAL.NeuronOrControl & 'neurons_or_control=1') & key;
            rel_data_corr=STIMANAL.ResponseVsCorr & rel_target;
            rel_data_stim=STIM.ROIResponseZscore   & rel_target & 'num_svd_components_removed=1';
            
            group_list = fetchn(rel_target,'photostim_group_num','ORDER BY photostim_group_num');
            num_svd_components_removed_vector = [1, 2, 10];
            
            colormap=viridis(numel(num_svd_components_removed_vector));
            if numel(group_list)<1
                return
            end
            
            threshold_for_event_vector = [0];
            for i_g = 1:1:numel(group_list)
                
                k.photostim_group_num=group_list(i_g);
                %                         DataStim{i_g} = fetchn(rel_data_stim & key & k,'response_mean_even', 'ORDER BY roi_number');
                %                         DataStim_pval{i_g} = fetchn(rel_data_stim & key & k,'response_p_value1_odd', 'ORDER BY roi_number')<=1;
                DataStim{i_g} = fetchn(rel_data_stim & key & k,'response_mean', 'ORDER BY roi_number');
                DataStim_pval{i_g} = fetchn(rel_data_stim & key & k,'response_p_value1', 'ORDER BY roi_number')<=1;
            end
            DataStim = cell2mat(DataStim)';
            DataStim_pval = cell2mat(DataStim_pval)';
            
            for i_th = 1:1:numel(threshold_for_event_vector)
                threshold= threshold_for_event_vector(i_th);
                
                for i_c = 1:1:numel(num_svd_components_removed_vector)
                    num_comp = num_svd_components_removed_vector(i_c);
                    
                    
                    key.threshold_for_event = threshold;
                    key.num_svd_components_removed_corr = num_comp;
                    
                    DataCorr = cell2mat(fetchn(rel_data_corr & key,'rois_corr', 'ORDER BY photostim_group_num'));
                    
                    % influence as a funciton of correlation
                    x=DataCorr(DataStim_pval);
                    y=DataStim(DataStim_pval);
                    corr_histogram_bins=prctile(x,[0:5:100]);%[-0.5:0.05:0.5];
                    x_bin=[];
                    y_bin=[];
                    for i_b = 1:1:numel(corr_histogram_bins)-1
                        idx_cor_bin = x>=corr_histogram_bins(i_b) & x<corr_histogram_bins(i_b+1);
                        x_bin (i_b) = mean(x(idx_cor_bin));
                        y_bin (i_b) = mean(y(idx_cor_bin));
                    end
                    
                    subplot(2,2,1)
                    hold on
                    plot(x_bin,y_bin, 'Color', colormap(i_c,:))
                    xlabel('Correlation, r');
                    ylabel ('Influence (dff)');
                    
                    % correlation as a funciton of influence
                    subplot(2,2,2)
                    x=DataStim(DataStim_pval);
                    y=DataCorr(DataStim_pval);
                    corr_histogram_bins=prctile(x,[0:10:100]);%[-0.5:0.05:0.5];
                    x_bin=[];
                    y_bin=[];
                    for i_b = 1:1:numel(corr_histogram_bins)-1
                        idx_cor_bin = x>=corr_histogram_bins(i_b) & x<corr_histogram_bins(i_b+1);
                        x_bin (i_b) = mean(x(idx_cor_bin));
                        y_bin (i_b) = mean(y(idx_cor_bin));
                    end
                    hold on
                    plot(x_bin,y_bin, 'Color', colormap(i_c,:))
                    xlabel ('Influence (dff)');
                    ylabel('Correlation, r');
                end
                
                
            end
        end
    end
end
