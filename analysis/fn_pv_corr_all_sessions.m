function fn_pv_corr_all_sessions(k, first_date, dir_save_figure, rel)


epoch_label={'delay','response'};

% FIGURE
%--------------------------------------------------------------------------
% Some WYSIWYG options:
figure;

set(gcf,'DefaultAxesFontSize',7);
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0.5 0.5 21 29.7]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[0 0 0 0]);

panel_width1=0.12;
panel_height1=panel_width1*0.7071;
horizontal_distance1=0.23;
vertical_distance1=0.15;


position_x1(1)=0.06;
position_x1(2)=position_x1(1)+horizontal_distance1;
position_x1(3)=position_x1(2)+horizontal_distance1;
position_x1(4)=position_x1(3)+horizontal_distance1;

position_y1(1)=0.8;
position_y1(2)=position_y1(1)-vertical_distance1;
position_y1(3)=position_y1(2)-vertical_distance1;
position_y1(4)=position_y1(3)-vertical_distance1;
position_y1(5)=position_y1(4)-vertical_distance1;



key=k;

key_first.session_date=first_date;
key_first=fetch(EXP2.Session & key_first);

key.multiple_sessions_uid = fetchn(IMG.FOVmultiSessions & key_first,'multiple_sessions_uid');

%  if flag_signif==6
%     roi.epoch{1}= fetchn(ANLI.IncludeROImultiSession2intersect	 & key_first, 'roi_number', 'ORDER BY roi_number');
%     roi.epoch{2} =  fetchn(ANLI.IncludeROImultiSession2intersect & key_first, 'roi_number', 'ORDER BY roi_number');
%  end



% k.session_date=date;
% 
% key=fetch(EXP2.Session & k);
% 
% if flag_signif==1
%     roi_delay = fetchn((ANLI.TaskSignifROI- IMG.ExcludeROI) & key & 'task_signif_name="LateDelay"' & 'task_signif_pval <=0.05', 'roi_number', 'ORDER BY roi_number');
%     roi_response = fetchn((ANLI.TaskSignifROI- IMG.ExcludeROI) & key & 'task_signif_name="Movement"' & 'task_signif_pval <=0.05', 'roi_number', 'ORDER BY roi_number');
% elseif flag_signif==2
%     roi_delay1 = fetchn((ANLI.TaskSignifROI- IMG.ExcludeROI) & key & 'task_signif_name="LateDelay"' & 'task_signif_pval <=0.05', 'roi_number', 'ORDER BY roi_number');
%     roi_delay2 = fetchn((ANLI.TaskSignifROI- IMG.ExcludeROI) & key & 'task_signif_name="Ramping"' & 'task_signif_pval <=0.0001', 'roi_number', 'ORDER BY roi_number');
%     roi_delay = unique([roi_delay1;roi_delay2],'sorted');
%     roi_response1 = fetchn((ANLI.TaskSignifROI- IMG.ExcludeROI) & key & 'task_signif_name="Movement"' & 'task_signif_pval <=0.05', 'roi_number', 'ORDER BY roi_number');
%     roi_response2 = fetchn((ANLI.TaskSignifROI- IMG.ExcludeROI) & key & 'task_signif_name="Ramping"' & 'task_signif_pval <=0.0001', 'roi_number', 'ORDER BY roi_number');
%     roi_response = unique([roi_response1;roi_response2],'sorted');
% elseif flag_signif==3
%     roi.epoch{1}= fetchn((ANLI.TaskSignifROIsomeEpoch - IMG.ExcludeROI) & key, 'roi_number', 'ORDER BY roi_number');
%     roi.epoch{2} =  fetchn((ANLI.TaskSignifROIsomeEpoch - IMG.ExcludeROI) & key, 'roi_number', 'ORDER BY roi_number');
%     elseif flag_signif==4
%     roi.epoch{1}= fetchn((ANLI.TaskSignifROIsomeEpoch3 - IMG.ExcludeROI) & key, 'roi_number', 'ORDER BY roi_number');
%     roi.epoch{2} =  fetchn((ANLI.TaskSignifROIsomeEpoch3 - IMG.ExcludeROI) & key, 'roi_number', 'ORDER BY roi_number');
%   elseif flag_signif==5
%     roi.epoch{1}= fetchn(ANLI.IncludeROI2 & key, 'roi_number', 'ORDER BY roi_number');
%     roi.epoch{2} =  fetchn(ANLI.IncludeROI2  & key, 'roi_number', 'ORDER BY roi_number');
%  elseif flag_signif==6
%     roi.epoch{1}= fetchn(ANLI.IncludeROImultiSession2intersect	 & key, 'roi_number', 'ORDER BY roi_number');
%     roi.epoch{2} =  fetchn(ANLI.IncludeROImultiSession2intersect  & key, 'roi_number', 'ORDER BY roi_number');
% 
% end


b=fetch(EXP2.BehaviorTrial*EXP2.SessionTrial & (IMG.FOVmultiSessions & key),'*','ORDER BY trial_uid');
b=struct2table(b);
trials(1).tr = find(contains(b.trial_instruction,'left') & contains(b.outcome,'hit') & contains(b.early_lick,'no early'));
trials(1).lick_direction='left';
trials(2).tr = find(contains(b.trial_instruction,'right') & contains(b.outcome,'hit') & contains(b.early_lick,'no early'));
trials(2).lick_direction='right';

for i_condition = 1:numel(trials)
    PV =[];
    
    
    current_trials=trials(i_condition).tr;
    for iTr=1:1:numel(current_trials)
        key.trial_uid = b.trial_uid(current_trials(iTr));
        key_trial = fetch((IMG.FOVmultiSessions*EXP2.SessionTrial & key));
        CTr = fetch(ANLI.FPSTHtrial & rel & key_trial,'*', 'ORDER BY roi_number');
        CTr=struct2table(CTr);
        t=CTr.psth_timestamps(1,:);
        time_sample_end=  CTr.time_sample_end(1);
        t_delay_idx= t>=time_sample_end & t<0;
        t_response_idx= t>=0 & t<2;
        psth_trial =CTr.psth_trial;
        PV.epoch{1}(:,iTr)= mean(psth_trial(:,t_delay_idx),2);
        PV.epoch{2}(:,iTr)= mean(psth_trial(:,t_response_idx),2);
    end
    
    subplot_shift1=0;
    if i_condition == 2
        subplot_shift1=1;
    end
    
    
    
    for i_epoch=1:1:numel(PV.epoch)
        PV.epoch_label{i_epoch} = epoch_label{i_epoch};
        PV.epoch_label{i_epoch} = epoch_label{i_epoch};
        
        subplot_shift2=0;
        if i_epoch == 2
            subplot_shift2=2;
        end
        
%         if flag_signif>0
%             PV.epoch{i_epoch} = PV.epoch{i_epoch} (roi.epoch{i_epoch},:);
%         end
        
        % correlation matrix of the PV across trials
        r.epoch{i_epoch}=corr(PV.epoch{i_epoch}', 'rows', 'pairwise');
        % blanking the diagonal
        diag_nan=[1:1:size(r.epoch{i_epoch},1)]+NaN; diag_mat = diag(diag_nan,0);
        r_blanked = r.epoch{i_epoch} + diag_mat;
        
        % PV histogram
        axes('position',[position_x1(1+subplot_shift1 + subplot_shift2) position_y1(1) panel_width1 panel_height1]);
        mask = tril(true(size(r.epoch{i_epoch})),-1);
        histogram(r.epoch{i_epoch}(mask));
        title(sprintf('Lick %s \n %s',trials(i_condition).lick_direction, PV.epoch_label{i_epoch}),'FontSize',8);
        xlabel('P.V. corr across trials','FontSize',8);
        ylabel('Counts','FontSize',8);
        
        % correlation matrix
        axes('position',[position_x1(1+subplot_shift1 + subplot_shift2) position_y1(2) panel_width1 panel_height1]);
       imagescnan(r_blanked,[0,1]);
        colormap(jet);
        if size (r_blanked,1)<500
    set(gca,'xtick',[1,100:100:size(r_blanked,1)],'ytick',100:100:size(r_blanked,1))
elseif size(r_blanked,1)>500 && size (r_blanked,1)<=1000
    set(gca,'xtick',[1,200:200:size(r_blanked,1)],'ytick',200:200:size(r_blanked,1))
elseif size(r_blanked,1)>1000
    set(gca,'xtick',[1,500:500:size(r_blanked,1)],'ytick',500:500:size(r_blanked,1))
end
        xlabel('Trials','FontSize',8);
        ylabel('Trials','FontSize',8);
        title('P.V. correlation','FontSize',8);
        
        %colorbar
        if i_condition==1
            axes('position',[position_x1(1+subplot_shift1 + subplot_shift2)+0.13 position_y1(2)-0.05 panel_width1/3 panel_height1]);
            c=colorbar;
            set(c,'Location','southoutside');
            axis off;
            box off;
        end
        
        % cluster pairwise distance
        axes('position',[position_x1(1+subplot_shift1 + subplot_shift2) position_y1(3) panel_width1 panel_height1]);
        [cl_id, mat, order]=fn_ClusterPVtrials(r.epoch{i_epoch});
        fn_plot_cluster_mat(mat);
        
        
        % cluster pairwise histogram
        axes('position',[position_x1(1+subplot_shift1 + subplot_shift2)+0.12 position_y1(3) panel_width1/2.5 panel_height1]);
        fn_plot_cluster_hist(cl_id, mat, order, r.epoch{i_epoch});
        
        %colorbar
        if i_condition==1
            axes('position',[position_x1(1+subplot_shift1 + subplot_shift2)+0.13 position_y1(3)-0.05 panel_width1/3 panel_height1]);
            c=colorbar;
            set(c,'Location','southoutside');
            axis off;
            box off;
        end
        
%                 % Cell by Trials  PV matrix (not correlation)
%         PVzscore= rescale(PV.epoch{i_epoch},'InputMin',0,'InputMax',1);
% 
% 
% %         if size (r_mat,1)<500
% %             set(gca,'xtick',[1,100:100:size(r_mat,1)],'ytick',100:100:size(r_mat,1))
% %         elseif size(r_mat,1)>500 && size (r_mat,1)<=1000
% %             set(gca,'xtick',[1,200:200:size(r_mat,1)],'ytick',200:200:size(r_mat,1))
% %         elseif size(r_mat,1)>1000
% %             set(gca,'xtick',[1,500:500:size(r_mat,1)],'ytick',500:500:size(r_mat,1))
% %         end
%   
% %         colorbar
%                 % cluster pairwise distance of Cell by Trials  PV matrix (not correlation)
%         axes('position',[position_x1(1+subplot_shift1 + subplot_shift2) position_y1(5) panel_width1 panel_height1]);
%         [cl_id2, cluster_mat2, order2]=fn_ClusterPVtrials(PVzscore);
%         fn_plot_cluster_mat(cluster_mat2);
% %         colorbar
%         
% 
%         axes('position',[position_x1(1+subplot_shift1 + subplot_shift2) position_y1(4) panel_width1 panel_height1]);
%         
%         PV_reordered= PVzscore(order2,order);
%         imagesc(PV_reordered);
%         colormap(jet);
%       xlabel('Trials','FontSize',8);
%                 ylabel('Neurons','FontSize',8);
%         title('P.V.','FontSize',8);
%         
        
        
%         % updating the cluster Table
%         key_TrialCluster=[];
%         key_TrialCluster = fetch(EXP2.Session &key);
%         key_TrialCluster.clustering_option_name = clustering_option_name;
%         key_TrialCluster.trial_epoch_name = PV.epoch_label{i_epoch};
%         key_TrialCluster = repmat(key_TrialCluster,numel(current_trials),1);
%         count =hist(cl_id, 1:max(cl_id));
%         [~,idx_sort_count] = sort(count,'descend');
%         
%         
%         for j_tr=1:1:numel(current_trials)
%             key_TrialCluster(j_tr).trial = current_trials(j_tr);
%             key_TrialCluster(j_tr).trial_cluster_id = cl_id(j_tr);
%             key_TrialCluster(j_tr).trial_cluster_group = find(idx_sort_count==cl_id(j_tr)); % group 1 - largest cluster, group 2 - second largest cluster etc.
%         end
%         
%         %deleting entries in case of duplicates to be able to overwrite
%         rel=fetch(ANLI.TrialCluster & key_TrialCluster);
%         if ~isempty(rel)
%             del(ANLI.TrialCluster&key_TrialCluster);
%         end
%         insert(ANLI.TrialCluster,key_TrialCluster);
        
    end
end

if isempty(dir(dir_save_figure))
    mkdir (dir_save_figure)
end

filename=['pv_' first_date];
figure_name_out=[ dir_save_figure filename];
eval(['print ', figure_name_out, ' -dtiff']);
clf;
end