%{
# Correlation versus influence, and Influence versus Correlation. Binned. Cells within the same lateral-axial bins are shuffled
-> EXP2.SessionEpoch
neurons_or_control     :boolean              # 1 - neurons, 0 control
response_p_val                  : double      # response p-value of influence cell pairs for inclusion. 1 means we take all pairs
num_svd_components_removed_corr : int     # how many of the first svd components were removed for computing correlations
---
influence_binned_by_corr                        :blob    # Influence versus Correlation.
corr_binned_by_influence                        :blob    # Correlation versus Iinfluence.
bins_influence_edges                            :blob    # bin-edges for binning influence
bins_corr_edges                                 :blob    # bin-edges for binning correlation
num_targets                                     :int     # num targets included
num_pairs                                       :int     # num pairs included

%}


classdef InfluenceVsCorrTraceSpontShuffled < dj.Computed
    properties
        keySource = EXP2.SessionEpoch & STIMANAL.Target2AllCorrTraceSpont & (EXP2.Session & STIM.ROIInfluence5);
    end
    methods(Access=protected)
        function makeTuples(self, key)
            close all;
            
            neurons_or_control_flag = [1,0]; % 1 neurons, 0 control sites
            neurons_or_control_label = { 'Neurons','Controls'};
            p_val=[1]; % for influence significance; %the code needs adjustment to include shuffling for other p-values
            num_svd_components_removed_vector_corr =[0,1,3,5,10];
            minimal_distance=25; %um, exlude all cells within minimal distance from target
            
            % bins
         bins_corr = [ -0.1,linspace(-0.05,0.05,11),0.1, 0.15, 0.2, 0.3,0.4,0.5, inf]; 
            bins_influence = [-inf, -0.3, linspace(-0.2,0.2,11),0.3, 0.4,0.5,0.75,1,1.25,1.5, inf];
            
            distance_lateral_bins = [0:10:500,inf]; % microns
            
            
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_fig = [dir_base  '\Photostim\influence_vs_corr\corr_trace_spont\shuffled\'];
            session_date = fetch1(EXP2.Session & key,'session_date');
            
            
            
            
            
            colormap=viridis(numel(num_svd_components_removed_vector_corr));
            
            for i_n = 1:1:numel(neurons_or_control_flag)
                key.neurons_or_control = neurons_or_control_flag(i_n);
                rel_target = IMG.PhotostimGroup & (STIMANAL.NeuronOrControl & key);
                rel_data_influence=STIM.ROIInfluence5   & rel_target & 'num_svd_components_removed=0';
                
                group_list = fetchn(rel_target,'photostim_group_num','ORDER BY photostim_group_num');
                if numel(group_list)<1
                    return
                end
                
                DataStim=cell(numel(group_list),1);
                DataStim_pval=cell(numel(group_list),1);
                DataStim_num_of_target_trials_used=cell(numel(group_list),1);
                Data_distance_lateral=cell(numel(group_list),1);
                Data_distance_axial=cell(numel(group_list),1);
                
                parfor i_g = 1:1:numel(group_list)
                    rel_data_influence_current = [rel_data_influence & ['photostim_group_num=' num2str(group_list(i_g))]];
                    DataStim{i_g} = fetchn(rel_data_influence_current,'response_mean', 'ORDER BY roi_number')';
                    DataStim_pval{i_g} = fetchn(rel_data_influence_current,'response_p_value1', 'ORDER BY roi_number')';
                    DataStim_num_of_target_trials_used{i_g}=fetchn(rel_data_influence_current,'num_of_target_trials_used', 'ORDER BY roi_number')';
                    Data_distance_lateral{i_g}=fetchn(rel_data_influence_current,'response_distance_lateral_um', 'ORDER BY roi_number')';
                    Data_distance_axial{i_g}=fetchn(rel_data_influence_current,'response_distance_axial_um', 'ORDER BY roi_number')';
                    
                end
                
                DataStim = cell2mat(DataStim);
                Data_distance_lateral = cell2mat(Data_distance_lateral);
                Data_distance_axial = cell2mat(Data_distance_axial);
                DataStim_num_of_target_trials_used = cell2mat(DataStim_num_of_target_trials_used);
                
                idx_include = true(size(Data_distance_lateral));
                idx_include(Data_distance_lateral<=minimal_distance  )=false; %exlude all cells within minimal distance from target
                idx_include(DataStim_num_of_target_trials_used==0  )=false; %exlude all cells within minimal distance from target
                
                DataStim(~idx_include)=NaN;
                DataStim=DataStim(:);
                
                Data_distance_lateral = Data_distance_lateral(:);
                Data_distance_axial = Data_distance_axial(:);

                
                for i_p=1:1:numel(p_val)
                    
                    idx_DataStim_pval=cell(numel(group_list),1);
                    parfor i_g = 1:1:numel(group_list)
                        idx_DataStim_pval{i_g} = DataStim_pval{i_g}<=p_val(i_p);
                    end
                    idx_DataStim_pval = cell2mat(idx_DataStim_pval);
                    idx_DataStim_pval= idx_DataStim_pval(:);
                    for i_c = 1:1:numel(num_svd_components_removed_vector_corr)
                        num_comp = num_svd_components_removed_vector_corr(i_c);
                        key_component_corr.num_svd_components_removed_corr = num_comp;
                        
                        
                        
                        rel_data_corr=STIMANAL.Target2AllCorrTraceSpont & rel_target & 'threshold_for_event=0' & key_component_corr;
                        DataCorr = cell2mat(fetchn(rel_data_corr,'rois_corr', 'ORDER BY photostim_group_num'));
                        
                        if numel(DataCorr(:)) ~= numel(DataStim(:))
                            a=1
                        end
                        
                        DataCorr(~idx_include)=NaN;
                        DataCorr=DataCorr(:);
                        

                            
                            distance_axial_bins = unique(Data_distance_axial);
                            for i_l=1:1:numel(distance_lateral_bins)-1
                                ix_l = Data_distance_lateral>=distance_lateral_bins(i_l) & Data_distance_lateral<distance_lateral_bins(i_l+1);
                                for i_a = 1:1:numel(distance_axial_bins)
                                    ix_a = Data_distance_axial==distance_axial_bins(i_a);
                                    ix_bin = ix_l & ix_a;
                                    data_in_bin = DataCorr(ix_bin);
                                    DataCorr(ix_bin) =data_in_bin(randperm(numel(data_in_bin)));
                                end
                            end
                        
                        
                        
                        % influence as a funciton of correlation
                        x=DataCorr(idx_DataStim_pval);
                        y=DataStim(idx_DataStim_pval);
                        [influence_binned_by_corr]= fn_bin_data(x,y,bins_corr);
                        
                        
                        x=DataStim(idx_DataStim_pval);
                        y=DataCorr(idx_DataStim_pval);
                        [corr_binned_by_influence]= fn_bin_data(x,y,bins_influence);
                        
                        
                        if num_svd_components_removed_vector_corr(i_c)==0
                            idx_subplot = 0;
                        else
                            idx_subplot = 2;
                        end
                        subplot(2,2,idx_subplot+1)
                        bins_influence_centers = bins_influence(1:end-1) + diff(bins_influence)/2;
                        hold on
                        plot(bins_influence_centers,corr_binned_by_influence,'-','Color',colormap(i_c,:))
                        xlabel ('Influence (dff)');
                        ylabel('Correlation, r');
                        if i_c==1
                            title(sprintf('Target: %s pval %.3f\n  anm%d session%d %s epoch%d ',neurons_or_control_label{i_n},p_val(i_p), key.subject_id,key.session,session_date, key.session_epoch_number));
                        end
                        
                        
                        subplot(2,2,idx_subplot+2)
                        hold on
                        bins_corr_centers = bins_corr(1:end-1) + diff(bins_corr)/2;
                        plot(bins_corr_centers,influence_binned_by_corr,'-','Color',colormap(i_c,:))
                        xlabel('Correlation, r');
                        ylabel ('Influence (dff)');
                        if i_c==1
                            title(sprintf('\n\nSVD removed %d',num_svd_components_removed_vector_corr(i_c)));
                        elseif i_c>=2
                            title(sprintf('\n\nSVD removed >=1'));
                        end
                        
                        
                        
                        
                        key_insert = key;
                        key_insert.num_svd_components_removed_corr = num_svd_components_removed_vector_corr(i_c);
                        key_insert.influence_binned_by_corr=influence_binned_by_corr;
                        key_insert.corr_binned_by_influence=corr_binned_by_influence;
                        key_insert.bins_corr_edges=bins_corr;
                        key_insert.bins_influence_edges=bins_influence;
                        key_insert.response_p_val=p_val(i_p);
                        key_insert.num_targets= numel(group_list);
                        key_insert.num_pairs=sum(~isnan(x));
                        
                        insert(self, key_insert);
                    end
                    
                    
                    dir_current_fig = [dir_fig '\' neurons_or_control_label{i_n} '\pval_' num2str(p_val(i_p)) '\'];
                    if isempty(dir(dir_current_fig))
                        mkdir (dir_current_fig)
                    end
                    filename = ['anm' num2str(key.subject_id) 's' num2str(key.session) '_' session_date '_' 'epoch' num2str(key.session_epoch_number)];
                    figure_name_out=[ dir_current_fig filename];
                    eval(['print ', figure_name_out, ' -dtiff  -r100']);
                    % eval(['print ', figure_name_out, ' -dpdf -r200']);
                    
                    clf;
                end
            end
        end
    end
end

