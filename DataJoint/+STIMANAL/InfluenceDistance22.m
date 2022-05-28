%{
# Responses of couple neurons to photostimulation, as a function of distance
-> EXP2.SessionEpoch
neurons_or_control                          : boolean             # 1 - neurons, 0 control
flag_withold_trials                         : boolean             # 1 define influence significance and sign based on odd trials, but compute the actual response based on even trials, 0 use all trials
flag_divide_by_std                          : boolean             # 1 normalize the response by its std, 0 don't normalize
flag_normalize_by_total                     : boolean             # 1 normalize by total number of pairs (e.g. includin non significant), 0 don't normalize
response_p_val                              : double              # response p-value for inclusion. 1 means we take all pairs
num_svd_components_removed                  : int     # how many of the first svd components were removed
---
is_volumetric                               : boolean             # 1 volumetric, 0 single plane
num_targets                                 : int                 # number of directly stimulated neurons (with significant response) or number of control targets (with non-significant responses)
num_pairs                                   : int                 # total number of cell-pairs included
distance_lateral_bins                       : blob                # lateral bins (um), edges
distance_axial_bins=null                    : blob                # axial positions (um), planes depth

response_lateral                            : longblob                # sum of response for all cell-pairs in each (lateral) bin, divided by the total number of all pairs (positive and negative) in that bin
response_lateral_excitation                 : longblob                # sum of response for all cell-pairs with positive response in each bin, divided by the total number of all pairs (positive and negative) in that bin
response_lateral_inhibition                 : longblob                # sum of response for all cell-pairs with negative response in each bin, divided by the total number of all pairs (positive and negative) in that bin
response_lateral_absolute                   : longblob                # sum of absolute value of tre response for all cell-pairs in each bin, divided by the total number of all pairs (positive and negative) in that bin

counts_lateral=null                         : longblob                # counts of cell-pairs, in each bin
counts_lateral_excitation=null              : longblob                # counts of cell-pairs with positive response, in each bin
counts_lateral_inhibition=null              : longblob                # counts of cell-pairs with negative response, in each bin

response_axial                              : longblob                # same for axial bins
response_axial_excitation                   : longblob                #
response_axial_inhibition                   : longblob                #
response_axial_absolute                     : longblob                #

response_axial_in_column                      : longblob                # same for axial bins
response_axial_in_column_excitation           : longblob                #
response_axial_in_column_inhibition           : longblob                #
response_axial_in_column_absolute             : longblob                #

response_axial_out_column                      : longblob                # same for axial bins
response_axial_out_column_excitation           : longblob                #
response_axial_out_column_inhibition           : longblob                #
response_axial_out_column_absolute             : longblob                #


counts_axial=null                         : longblob                #
counts_axial_excitation=null              : longblob                #
counts_axial_inhibition=null              : longblob                #

response_2d=null                          : longblob                # ame for lateral-axial bin
response_2d_excitation=null               : longblob                #
response_2d_inhibition=null               : longblob                #
response_2d_absolute=null                 : longblob                #

counts_2d=null                              : longblob                #
counts_2d_excitation=null                   : longblob                #
counts_2d_inhibition =null                  : longblob                #
%}


classdef InfluenceDistance22 < dj.Computed
    properties
        keySource = (EXP2.SessionEpoch & 'flag_photostim_epoch =1') & STIM.ROIResponseDirect2 & (STIMANAL.SessionEpochsIncludedFinal & 'flag_include=1');
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            rel=STIM.ROIInfluence2;
            distance_lateral_bins = [0:10:500]; % microns
            column_radius(1) =100; % microns
            column_radius(2) =250; % microns
            
            minimal_distance=25; % for within column calculations we don't consider responses within minimal_distance
            num_svd_components_removed_vector = [0];
            pval=[0.01, 0.05, 1];
            neurons_or_control_flag = [1,0];
            flag_withold_trials = [0,1];
            flag_normalize_by_total = [1];
            flag_divide_by_std = [0]; % 1 divide the response by std. 0 don't divide
               
%             minimal_distance=25; % for within column calculations we don't consider responses within minimal_distance
%             num_svd_components_removed_vector = [0];
%             pval=[0.001, 0.01, 0.05, 0.1, 0.2,   1];
%             neurons_or_control_flag = [1,0];
%             flag_withold_trials = [1];
%             flag_normalize_by_total = [1];
%             flag_divide_by_std = [0]; % 1 divide the response by std. 0 don't divide
            
            for i_n = 1:1:numel(neurons_or_control_flag)
                kkk=key;
                kkk.neurons_or_control = neurons_or_control_flag(i_n);
                rel_direct= STIMANAL.NeuronOrControl2 & kkk;
                rel_group_targets =  IMG.PhotostimGroup & rel_direct; % we do it to get rid of the roi column
                DATA_all=fetch((rel & key & rel_group_targets)& 'num_svd_components_removed=0' & 'num_of_target_trials_used>20','*');
                
                if isempty(DATA_all)
                   return; 
                end

                parfor i_p = 1:1:numel(pval) %parfor

                    for i_c = 1:1:numel(num_svd_components_removed_vector)
                        kk=key;
                        kk.num_svd_components_removed=num_svd_components_removed_vector(i_c);
                        
                        for i_total = 1:1:numel(flag_normalize_by_total)
                            for i_w = 1:1:numel(flag_withold_trials)
                                for i_std = 1:1:numel(flag_divide_by_std)
                                    rel_current = rel & kk;
                                    k =STIMANAL_fn_distance_binning_coupled_response(rel_current, key,DATA_all,rel_group_targets, pval(i_p), distance_lateral_bins,  column_radius,minimal_distance, flag_withold_trials(i_w),flag_normalize_by_total(i_total),flag_divide_by_std(i_std));
                                    k.flag_withold_trials = flag_withold_trials(i_w);
                                    k.flag_normalize_by_total = flag_normalize_by_total(i_total);
                                    k.flag_divide_by_std = flag_divide_by_std(i_std);
                                    k.neurons_or_control = neurons_or_control_flag(i_n);
                                    k.num_svd_components_removed = num_svd_components_removed_vector(i_c);
                                    insert(self,k);
                                end
                            end
                        end
                        
                    end
                end
            end
        end
    end
end