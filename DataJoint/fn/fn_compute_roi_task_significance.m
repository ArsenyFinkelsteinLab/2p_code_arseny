function k_insert = fn_compute_roi_task_significance (psth_roi_tr_fr, trials1, trials2, tint1, tint2, psth_t_vector, k_insert)

k_insert.signif_time1_st =  tint1(1);
k_insert.signif_time1_end = tint1(2);
k_insert.signif_time2_st = tint2(1);
k_insert.signif_time2_end = tint2(2);


%set 1 - trial average and variance, for the specified time-interval for all units
ix_t = find(psth_t_vector >= tint1(1) & psth_t_vector < tint1(2));
set1 = squeeze(nanmean(psth_roi_tr_fr( :, trials1, ix_t), 3));
% set1avg = squeeze(nanmean(set1, 2));
% set1var =  squeeze(nanvar(set1,[], 2));
% unit_trials1 = sum(~isnan(set1),2);

%set 2 - trial average and variance, for the specified time-interval for all units
ix_t = find(psth_t_vector >= tint2(1) & psth_t_vector < tint2(2));
set2 = squeeze(nanmean(psth_roi_tr_fr( :, trials2, ix_t), 3));
% set2avg = squeeze(nanmean(set2, 2));
% set2var =  squeeze(nanvar(set2,[], 2));
% unit_trials2 = sum(~isnan(set2),2);


k_insert =repmat(k_insert,size(set1,1),1);

for i_roi = 1:1:size(set1,1)
    if ( sum(~isnan(set1(i_roi,:)))==0    || sum(~isnan(set2(i_roi,:)))==0 )
        pVal(i_roi) =NaN;
    else
        pVal(i_roi) = ranksum(set1(i_roi,:),set2(i_roi,:));
    end
    k_insert(i_roi).task_signif_pval =  pVal(i_roi) ;
    k_insert(i_roi).roi_number = i_roi;
    
end


