function key =STIMANAL_fn_distance_binning_coupled_response(rel, key,DATA_all,rel_group_targets, p_val, distance_lateral_bins,  column_radius,minimal_distance, flag_withold_trials, flag_normalize_by_total,flag_divide_by_std)
rel = rel & key;
if flag_withold_trials==0
    rel = rel & ['response_p_value1<=' num2str(p_val)];
else
    rel = rel & ['response_p_value1_odd<=' num2str(p_val)];
end


% DATA=fetch((rel & rel_group_targets) & 'num_of_baseline_trials_used>0' & 'num_of_target_trials_used>0','*'); % we take all the cell pairs except those within 20 micron of stimulation laterally (regardless of depth)
DATA=fetch((rel & rel_group_targets) & 'num_of_target_trials_used>0','*'); % we take all the cell pairs except those within 20 micron of stimulation laterally (regardless of depth)

if flag_divide_by_std==0
    F_mean=[DATA.response_mean]';
    F_mean_odd=[DATA.response_mean_odd]';
    F_mean_even=[DATA.response_mean_even]';
elseif flag_divide_by_std==1
    F_mean=[DATA.response_mean_over_std]';
    F_mean_odd=[DATA.response_mean_over_std_odd]'; % to fix it later
    F_mean_even=[DATA.response_mean_over_std_even]'; % to fix it later
end

if flag_withold_trials==0
    ix_excit= F_mean>0;
    ix_inhbit= F_mean<0;
    F_data = F_mean;
else
    ix_excit= F_mean_odd>0;
    ix_inhbit= F_mean_odd<0;
    F_data = F_mean_even;
end

distance_lateral=[DATA.response_distance_lateral_um]';
distance_axial=[DATA.response_distance_axial_um]';

distance_axial_bins = unique(distance_axial);
if numel(distance_axial_bins)>0
    key.is_volumetric=true;
else
    key.is_volumetric=false;
end




distance_lateral_all=[DATA_all.response_distance_lateral_um]';
distance_axial_all=[DATA_all.response_distance_axial_um]';


%% Lateral binning
for i_l=1:1:numel(distance_lateral_bins)-1
    ix_l = distance_lateral>=distance_lateral_bins(i_l) & distance_lateral<distance_lateral_bins(i_l+1);
    ix_l_all = distance_lateral_all>=distance_lateral_bins(i_l) & distance_lateral_all<distance_lateral_bins(i_l+1);
    
    if flag_normalize_by_total==1
        normalize_all=sum(ix_l_all);
        normalize_excitatory=sum(ix_l_all);
        normalize_inhibitory=sum(ix_l_all);
    elseif  flag_normalize_by_total==0
        normalize_all=sum(ix_l);
        normalize_excitatory=sum(ix_l & ix_excit);
        normalize_inhibitory=sum(ix_l & ix_inhbit);
    end
    
    
    if sum(ix_l)>0
        key.response_lateral(i_l) =single(nansum(F_data(ix_l))/normalize_all);
        key.response_lateral_absolute(i_l) = single(nansum(abs(F_data(ix_l)))/normalize_all);
    else
        key.response_lateral(i_l) =NaN;
        key.response_lateral_absolute(i_l) = NaN;
    end
    if sum(ix_l & ix_excit)>0
        key.response_lateral_excitation(i_l) =single(nansum(F_data(ix_l & ix_excit))/normalize_excitatory);
    else
        key.response_lateral_excitation(i_l) =NaN;
    end
    if sum(ix_l & ix_inhbit)>0
        key.response_lateral_inhibition(i_l) =single(nansum(F_data(ix_l & ix_inhbit))/normalize_inhibitory);
    else
        key.response_lateral_inhibition(i_l) =NaN;
    end
    
    %     key.counts_lateral(i_l)=single(sum(ix_l));
    %     key.counts_lateral_excitation(i_l) =single(sum(ix_l & ix_excit));
    %     key.counts_lateral_inhibition(i_l) =single(sum(ix_l & ix_inhbit));
    
    %% 2D lateral X axial binning
    for i_a = 1:1:numel(distance_axial_bins)
        ix_a = distance_axial==distance_axial_bins(i_a);
        ix_a_all = distance_axial_all==distance_axial_bins(i_a);
        
        if flag_normalize_by_total==1
            normalize_all=sum(ix_l_all & ix_a_all);
            normalize_excitatory=sum(ix_l_all & ix_a_all);
            normalize_inhibitory=sum(ix_l_all & ix_a_all);
        elseif  flag_normalize_by_total==0
            normalize_all=sum(ix_l & ix_a);
            normalize_excitatory=sum(ix_l & ix_a & ix_excit);
            normalize_inhibitory=sum(ix_l & ix_a & ix_inhbit);
        end
        
        if sum(ix_l & ix_a)>0
            key.response_2d(i_a,i_l) =single(nansum(F_data(ix_l & ix_a))/normalize_all);
            key.response_2d_absolute(i_a,i_l) = single(nansum(abs(F_data(ix_l & ix_a)))/normalize_all);
        else
            key.response_2d(i_a,i_l) =NaN;
            key.response_2d_absolute(i_a,i_l) = NaN;
        end
        if sum(ix_l & ix_a & ix_excit)>0
            key.response_2d_excitation(i_a,i_l) =single(nansum(F_data(ix_l & ix_a & ix_excit))/normalize_excitatory);
        else
            key.response_2d_excitation(i_a,i_l) =NaN;
        end
        if sum(ix_l & ix_a & ix_inhbit)>0
            key.response_2d_inhibition(i_a,i_l) =single(nansum(F_data(ix_l & ix_a & ix_inhbit))/normalize_inhibitory);
        else
            key.response_2d_inhibition(i_a,i_l) =NaN;
        end
        
        key.counts_2d(i_a,i_l)=single(sum(ix_l & ix_a));
        key.counts_2d_excitation(i_a,i_l) =single(sum(ix_l & ix_a & ix_excit));
        key.counts_2d_inhibition(i_a,i_l) =single(sum(ix_l & ix_a & ix_inhbit));
        
    end
end

%% Axial binning
for i_a=1:1:numel(distance_axial_bins)
    ix_a = distance_axial==distance_axial_bins(i_a);
    
    ix_a_all = distance_axial_all==distance_axial_bins(i_a);
    
    if flag_normalize_by_total==1
        normalize_all=sum(ix_a_all);
        normalize_excitatory=sum(ix_a_all);
        normalize_inhibitory=sum(ix_a_all);
    elseif  flag_normalize_by_total==0
        normalize_all=sum(ix_a);
        normalize_excitatory=sum(ix_a & ix_excit);
        normalize_inhibitory=sum(ix_a & ix_inhbit);
    end
    
    
    if sum(ix_a)>0
        key.response_axial(i_a) =single(nansum(F_data(ix_a))/normalize_all);
        key.response_axial_absolute(i_a) = single(nansum(abs(F_data(ix_a)))/normalize_all);
    else
        key.response_axial(i_a) =NaN;
        key.response_axial_absolute(i_a) = NaN;
    end
    if sum(ix_a & ix_excit)>0
        key.response_axial_excitation(i_a) =single(nansum(F_data(ix_a & ix_excit))/normalize_excitatory);
    else
        key.response_axial_excitation(i_a) =NaN;
    end
    if sum(ix_a & ix_inhbit)>0
        key.response_axial_inhibition(i_a) =single(nansum(F_data(ix_a & ix_inhbit))/normalize_inhibitory);
    else
        key.response_axial_inhibition(i_a) =NaN;
    end
    %     key.counts_axial(i_a)=single(sum(ix_a));
    %     key.counts_axial_excitation(i_a) =single(sum(ix_a & ix_excit));
    %     key.counts_axial_inhibition(i_a) =single(sum(ix_a & ix_inhbit));
end


%% Axial binning within a column
for i_a=1:1:numel(distance_axial_bins)
    ix_a = distance_axial==distance_axial_bins(i_a);
    ix_a_all = distance_axial_all==distance_axial_bins(i_a);
    ix_column_in  =   distance_lateral>=minimal_distance & distance_lateral<=column_radius(1) & ix_a;
    ix_column_in_all  =   distance_lateral_all>=minimal_distance & distance_lateral_all<=column_radius(1) & ix_a_all;
    
    if flag_normalize_by_total==1
        normalize_all=sum(ix_column_in_all);
        normalize_excitatory=sum(ix_column_in_all);
        normalize_inhibitory=sum(ix_column_in_all);
    elseif  flag_normalize_by_total==0
        normalize_all=sum(ix_column_in);
        normalize_excitatory=sum(ix_column_in & ix_excit);
        normalize_inhibitory=sum(ix_column_in & ix_inhbit);
    end
    
    
    if sum(ix_column_in)>0
        key.response_axial_in_column(i_a) =single(nansum(F_data(ix_column_in))/normalize_all);
        key.response_axial_in_column_absolute(i_a) = single(nansum(abs(F_data(ix_column_in)))/normalize_all);
    else
        key.response_axial_in_column(i_a) =NaN;
        key.response_axial_in_column_absolute(i_a) = NaN;
    end
    if sum(ix_column_in & ix_excit)>0
        key.response_axial_in_column_excitation(i_a) =single(nansum(F_data(ix_column_in & ix_excit))/normalize_excitatory);
    else
        key.response_axial_in_column_excitation(i_a) =NaN;
    end
    if sum(ix_column_in & ix_inhbit)>0
        key.response_axial_in_column_inhibition(i_a) =single(nansum(F_data(ix_column_in & ix_inhbit))/normalize_inhibitory);
    else
        key.response_axial_in_column_inhibition(i_a) =NaN;
    end
end



%% Axial binning outside of a column
for i_a=1:1:numel(distance_axial_bins)
    ix_a = distance_axial==distance_axial_bins(i_a);
    ix_a_all = distance_axial_all==distance_axial_bins(i_a);
    ix_column_out  =   distance_lateral>column_radius(1)  & distance_lateral<=column_radius(2) & ix_a;
    ix_column_out_all  =   distance_lateral_all>column_radius(1) & distance_lateral_all<=column_radius(2) & ix_a_all;
    
    if flag_normalize_by_total==1
        normalize_all=sum(ix_column_out_all);
        normalize_excitatory=sum(ix_column_out_all);
        normalize_inhibitory=sum(ix_column_out_all);
    elseif  flag_normalize_by_total==0
        normalize_all=sum(ix_column_out);
        normalize_excitatory=sum(ix_column_out & ix_excit);
        normalize_inhibitory=sum(ix_column_out & ix_inhbit);
    end
    
    if sum(ix_column_out)>0
        key.response_axial_out_column(i_a) =single(nansum(F_data(ix_column_out))/normalize_all);
        key.response_axial_out_column_absolute(i_a) = single(nansum(abs(F_data(ix_column_out)))/normalize_all);
    else
        key.response_axial_out_column(i_a) =NaN;
        key.response_axial_out_column_absolute(i_a) = NaN;
    end
    if sum(ix_column_out & ix_excit)>0
        key.response_axial_out_column_excitation(i_a) =single(nansum(F_data(ix_column_out & ix_excit))/normalize_excitatory);
    else
        key.response_axial_out_column_excitation(i_a) =NaN;
    end
    if sum(ix_column_out & ix_inhbit)>0
        key.response_axial_out_column_inhibition(i_a) =single(nansum(F_data(ix_column_out & ix_inhbit))/normalize_inhibitory);
    else
        key.response_axial_out_column_inhibition(i_a) =NaN;
    end
end

% fff=fetch1(IMG.PhotostimDATfile & key,'dat_file')
key.response_p_val=p_val;
key.num_pairs = numel(F_data);
key.distance_lateral_bins  = distance_lateral_bins;
key.distance_axial_bins  = distance_axial_bins;
key.num_targets=rel_group_targets.count;




