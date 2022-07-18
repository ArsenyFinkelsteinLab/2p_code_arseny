%{
# Correlation versus influence, and Influence versus Correlation. Binned. Cells within the same lateral-axial bins are shuffled
-> EXP2.SessionEpoch
neurons_or_control     :boolean              # 1 - neurons, 0 control
response_p_val                  : double      # response p-value of influence cell pairs for inclusion. 1 means we take all pairs
---
influence_binned_by_corr                        :blob    # Influence versus Correlation.
corr_binned_by_influence                        :blob    # Correlation versus Iinfluence.
bins_influence_edges                            :blob    # bin-edges for binning influence
bins_corr_edges                                 :blob    # bin-edges for binning correlation
num_targets                                     :int     # num targets included
num_pairs                                       :int     # num pairs included
%}


classdef InfluenceVsCorrConcatShuffled4 < dj.Computed
    properties
        keySource = EXP2.SessionEpoch & STIMANAL.Target2AllCorrConcat & STIM.ROIInfluence2;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            close all;
            
            neurons_or_control_flag = [1]; % 1 neurons, 0 control sites
            neurons_or_control_label = { 'Neurons','Controls'};
            p_val=[1]; % for influence significance; %the code needs adjustment to include shuffling for other p-values
            minimal_distance=25; %um, lateral;  exlude all cells within minimal distance from target
            maximal_distance=100; %um lateral;  exlude all cells further than maximal distance from target
            
            % bins
            bins_corr = [linspace(-1,1,7)]; 
            
            %             bins_influence = [-inf,linspace(-0.1,0.2,6),inf];
            %             bins_influence = [-inf,linspace(-0.1,0.4,6),inf];
            
            bins_influence = [-inf,linspace(-0.2,0.5,8),inf];
            
            %             bins_influence=bins_influence(4:end);
            
            distance_lateral_bins = [0:10:500,inf]; % microns
            
            
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_fig = [dir_base  '\Photostim\influence_vs_corr_new\corr_concat4\shuffled\'];
            session_date = fetch1(EXP2.Session & key,'session_date');
            
            
            rel_data_corr =STIMANAL.Target2AllCorrConcat;
            rel_data_influence=STIM.ROIInfluence2;
            rel_data_signal = LICK2D.ROILick2DContactenatedSpikes;
            k_psth =key;
            k_psth=rmfield(k_psth,'session_epoch_type');
            k_psth=rmfield(k_psth,'session_epoch_number');
            rel_roi = (IMG.ROI - IMG.ROIBad) & key;
            
            
            
            for i_n = 1:1:numel(neurons_or_control_flag)
                key.neurons_or_control = neurons_or_control_flag(i_n);
                rel_target = IMG.PhotostimGroup & (STIMANAL.NeuronOrControl2 & key);
                rel_data_influence2=rel_data_influence   & rel_target & 'num_svd_components_removed=0';
                
                group_list = fetchn(rel_target,'photostim_group_num','ORDER BY photostim_group_num');
                if numel(group_list)<1
                    return
                end
                
                rel_target_signif_by_psth = (STIM.ROIResponseDirect2 &  rel_target) &    (IMG.ROI &  (rel_data_signal & k_psth & 'psth_position_concat_regularreward_odd_even_corr>=0'));
                group_list_signif = fetchn(rel_target_signif_by_psth,'photostim_group_num','ORDER BY photostim_group_num');
                idx_group_list_signif = ismember(group_list,group_list_signif);
                
                
                DataStim=cell(numel(group_list),1);
                DataStim_pval=cell(numel(group_list),1);
                %                 DataStim_num_of_baseline_trials_used=cell(numel(group_list),1);
                DataStim_num_of_target_trials_used=cell(numel(group_list),1);
                DataStim_distance_lateral=cell(numel(group_list),1);
                DataStim_distance_axial=cell(numel(group_list),1);
                
                parfor i_g = 1:1:numel(group_list)
                    rel_data_influence_current = [rel_data_influence2 & ['photostim_group_num=' num2str(group_list(i_g))]];
                    DataStim{i_g} = fetchn(rel_data_influence_current,'response_mean', 'ORDER BY roi_number')';
                    DataStim_pval{i_g} = fetchn(rel_data_influence_current,'response_p_value1', 'ORDER BY roi_number')';
                    %                     DataStim_num_of_baseline_trials_used{i_g}=fetchn(rel_data_influence_current,'num_of_baseline_trials_used', 'ORDER BY roi_number')';
                    DataStim_num_of_target_trials_used{i_g}=fetchn(rel_data_influence_current,'num_of_target_trials_used', 'ORDER BY roi_number')';
                    DataStim_distance_lateral{i_g}=fetchn(rel_data_influence_current,'response_distance_lateral_um', 'ORDER BY roi_number')';
                    DataStim_distance_axial{i_g}=fetchn(rel_data_influence_current,'response_distance_axial_um', 'ORDER BY roi_number')';
                    
                end
                
                DataStim = cell2mat(DataStim);
                DataStim_distance_lateral = cell2mat(DataStim_distance_lateral);
                DataStim_distance_axial = cell2mat(DataStim_distance_axial);
                %                 DataStim_num_of_baseline_trials_used = cell2mat(DataStim_num_of_baseline_trials_used);
                DataStim_num_of_target_trials_used = cell2mat(DataStim_num_of_target_trials_used);
                
                idx_include = true(size(DataStim_distance_lateral));
                idx_include(DataStim_distance_lateral<=minimal_distance  )=false; %exlude all cells within minimal distance from target
                idx_include(DataStim_distance_lateral>maximal_distance  )=false; %exlude all cells further than maximal distance from target
                %                 idx_include(DataStim_num_of_baseline_trials_used==0  )=false;
                idx_include(DataStim_num_of_target_trials_used==0  )=false;
                
                DataStim(~idx_include)=NaN;
                
                for i_g = 1:1:numel(group_list)
                    current_DataStim = DataStim(i_g,:);
                    current_distance_lateral= DataStim_distance_lateral(i_g,:);
                    current_distance_axial= DataStim_distance_axial(i_g,:);
                    
                    distance_axial_bins = unique(current_distance_axial(:));
                    for i_l=1:1:numel(distance_lateral_bins)-1
                        ix_l = current_distance_lateral>=distance_lateral_bins(i_l) & current_distance_lateral<distance_lateral_bins(i_l+1);
                        for i_a = 1:1:numel(distance_axial_bins)
                            ix_a = current_distance_axial==distance_axial_bins(i_a);
                            ix_bin = ix_l & ix_a;
                            data_in_bin = current_DataStim(ix_bin);
                            current_DataStim(ix_bin) =data_in_bin(randperm(numel(data_in_bin)));
                        end
                    end
                    DataStim(i_g,:)=current_DataStim;
                end
                
                
                for i_p=1:1:numel(p_val)
                    
                    idx_DataStim_pval=cell(numel(group_list),1);
                    parfor i_g = 1:1:numel(group_list)
                        idx_DataStim_pval{i_g} = DataStim_pval{i_g}<=p_val(i_p);
                    end
                    idx_DataStim_pval = cell2mat(idx_DataStim_pval);
                    
                    bins_corr_to_use = bins_corr;
                    
                    
                    rel_data_corr_current=rel_data_corr & rel_target ;
                    DataCorr = cell2mat(fetchn(rel_data_corr_current,'rois_corr', 'ORDER BY photostim_group_num'));
                    DataCorr(~idx_include)=NaN;
                    
                    
                    %% exclude based on PSTH significance
                    roi_psth_signif = fetchn(rel_data_signal & k_psth & rel_roi & 'psth_position_concat_regularreward_odd_even_corr>=0', 'roi_number', 'ORDER BY roi_number');
                    roi_psth_all = fetchn(rel_data_signal & k_psth & rel_roi, 'roi_number', 'ORDER BY roi_number');
                    idx_psth_signif=ismember(roi_psth_all,roi_psth_signif);
                    
                    DataCorr =DataCorr(idx_group_list_signif,idx_psth_signif);
                    idx_include =idx_include(idx_group_list_signif,idx_psth_signif);
                    idx_DataStim_pval =idx_DataStim_pval(idx_group_list_signif,idx_psth_signif);
                    DataStim =DataStim(idx_group_list_signif,idx_psth_signif);
                    %
                    
                    % influence as a funciton of correlation
                    x=DataCorr(idx_DataStim_pval);
                    y=DataStim(idx_DataStim_pval);
                    [influence_binned_by_corr]= fn_bin_data(x,y,bins_corr_to_use);
                    
                    
                    x=DataStim(idx_DataStim_pval);
                    y=DataCorr(idx_DataStim_pval);
                    [corr_binned_by_influence]= fn_bin_data(x,y,bins_influence);
                    
                    
                    idx_subplot = 0;
                    
                    subplot(2,2,idx_subplot+1)
                    bins_influence_centers = bins_influence(1:end-1) + diff(bins_influence)/2;
                    hold on
                    plot(bins_influence_centers,corr_binned_by_influence,'-')
                    xlabel ('Influence (dff)');
                    ylabel('Correlation, r');
                    title(sprintf('Target: %s pval %.3f\n  anm%d session%d %s epoch%d ',neurons_or_control_label{i_n},p_val(i_p), key.subject_id,key.session,session_date, key.session_epoch_number));
                    
                    
                    
                    subplot(2,2,idx_subplot+2)
                    hold on
                    bins_corr_centers = bins_corr_to_use(1:end-1) + diff(bins_corr_to_use)/2;
                    plot(bins_corr_centers,influence_binned_by_corr,'-')
                    xlabel('Correlation, r');
                    ylabel ('Influence (dff)');
                    
                    
                    
                    
                    
                    key_insert = key;
                    key_insert.influence_binned_by_corr=influence_binned_by_corr;
                    key_insert.corr_binned_by_influence=corr_binned_by_influence;
                    key_insert.bins_corr_edges=bins_corr_to_use;
                    key_insert.bins_influence_edges=bins_influence;
                    key_insert.response_p_val=p_val(i_p);
                    key_insert.num_targets= numel(group_list(idx_group_list_signif));
                    key_insert.num_pairs=sum(~isnan(x));
                    
                    insert(self, key_insert);
                    
                    
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

