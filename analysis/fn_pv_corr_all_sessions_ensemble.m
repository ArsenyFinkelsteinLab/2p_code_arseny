function fn_pv_corr_all_sessions_ensemble(k, first_date, dir_save_figure, rel)


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
position_y1(6)=position_y1(5)-vertical_distance1;



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


b=fetch(EXP2.BehaviorTrial*EXP2.SessionTrial & (IMG.FOVmultiSessions & key) & 'early_lick="no early"' & 'outcome="hit"','*','ORDER BY trial_uid');
b=struct2table(b);
% trials(1).tr = find(contains(b.trial_instruction,'left') & contains(b.outcome,'hit') & contains(b.early_lick,'no early'));
% trials(1).lick_direction='left';
% trials(2).tr = find(contains(b.trial_instruction,'right') & contains(b.outcome,'hit') & contains(b.early_lick,'no early'));
% trials(2).lick_direction='right';

% trials(1).tr = find( contains(b.early_lick,'no early') & contains(b.outcome,'hit'));
% trials(1).lick_direction='hit';
% trials(2).tr = find(contains(b.early_lick,'no early') & contains(b.outcome,'miss'));
% trials(2).lick_direction='miss';


% trials(1).tr = find( contains(b.early_lick,'no early'));
% trials(1).lick_direction='all';

% trials(1).tr 

PV =[];


%     current_trials=trials(i_condition).tr;
current_trials=[b.trial];
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
    
for i_condition = 1%1:numel(trials)
    PV_current=[];
    r =[];
    r_mat_trials=[];
    r_mat_cells=[];
    
    subplot_shift1=0;
    if i_condition == 2
        subplot_shift1=1;
    end
    
    
    
    for i_epoch=1%:1:numel(PV.epoch)
        PV.epoch_label{i_epoch} = epoch_label{i_epoch};
        PV.epoch_label{i_epoch} = epoch_label{i_epoch};
        
        subplot_shift2=0;
        if i_epoch == 2
            subplot_shift2=2;
        end
        
        % correlation matrix of the PV across trials
%         PV_current =PV.epoch{i_epoch};
              PV_current = [PV.epoch{1},PV.epoch{2}];

        for i_c=1:1:size(PV_current,1)
            z=zscore( PV_current(i_c,:));
            PV_current(i_c,:)=       z>1; %binarizing
        end
        
        
%         PV_current= PV_current(:,trials(i_condition).tr);

        r_mat_trials=corr(PV_current, 'rows', 'pairwise');
        r_mat_cells=corr(PV_current', 'rows', 'pairwise');
        
        r_mat_trials(isnan(r_mat_trials))=0;
                r_mat_cells(isnan(r_mat_cells))=0;

        %         % blanking the diagonal
        %         diag_nan=[1:1:size(r.epoch{i_epoch},1)]+NaN; diag_mat = diag(diag_nan,0);
        %         r_mat = r.epoch{i_epoch} + diag_mat;
        %
        %         r_blanked = r.epoch{i_epoch};
        
        %% Clustering Cells
        
        %         % PV histogram
        %         axes('position',[position_x1(1+subplot_shift1 + subplot_shift2) position_y1(1) panel_width1 panel_height1]);
        %         mask = tril(true(size(r_mat_trials)),-1);
        %         histogram(r_mat_trials(mask));
        %         title(sprintf('Lick %s \n %s',trials(i_condition).lick_direction, PV.epoch_label{i_epoch}),'FontSize',8);
        %         xlabel('Trial correlations between cell pairs','FontSize',8);
        %         ylabel('Counts','FontSize',8);
        
        % correlation matrix
        axes('position',[position_x1(1+subplot_shift1 + subplot_shift2) position_y1(2) panel_width1 panel_height1]);
        imagesc(r_mat_cells,[0,1]);
        colormap(jet);
        xlabel('Cells','FontSize',8);
        ylabel('Cells','FontSize',8);
        title('Correlation','FontSize',8);
        axis equal
        axis tight;
        
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
        [cl_id_cells, cluster_mat_cells, order_cells]=fn_ClusterPVtrials(r_mat_cells);
        fn_plot_cluster_mat(cluster_mat_cells);
        
        
        % cluster pairwise histogram
        axes('position',[position_x1(1+subplot_shift1 + subplot_shift2)+0.12 position_y1(3) panel_width1/2.5 panel_height1]);
        fn_plot_cluster_hist(cl_id_cells, cluster_mat_cells, order_cells, r_mat_cells);
        
        %colorbar
        if i_condition==1
            axes('position',[position_x1(1+subplot_shift1 + subplot_shift2)+0.13 position_y1(3)-0.05 panel_width1/3 panel_height1]);
            c=colorbar;
            set(c,'Location','southoutside');
            axis off;
            box off;
        end
        
        
        %% Clustering trials
        
        % correlation matrix
        axes('position',[position_x1(1+subplot_shift1 + subplot_shift2) position_y1(4) panel_width1 panel_height1]);
        imagesc(r_mat_trials,[0,1]);
        colormap(jet);
        xlabel('Trials','FontSize',8);
        ylabel('Trials','FontSize',8);
        title('Correlation','FontSize',8);
        axis equal
        axis tight;
        
        %colorbar
        if i_condition==1
            axes('position',[position_x1(1+subplot_shift1 + subplot_shift2)+0.13 position_y1(4)-0.05 panel_width1/3 panel_height1]);
            c=colorbar;
            set(c,'Location','southoutside');
            axis off;
            box off;
        end
        
        % cluster pairwise distance
        axes('position',[position_x1(1+subplot_shift1 + subplot_shift2) position_y1(5) panel_width1 panel_height1]);
        [cl_id_trials, cluster_mat_trials, order_trials]=fn_ClusterPVtrials(r_mat_trials);
        fn_plot_cluster_mat(cluster_mat_trials);
        
        
        % cluster pairwise histogram
        axes('position',[position_x1(1+subplot_shift1 + subplot_shift2)+0.12 position_y1(5) panel_width1/2.5 panel_height1]);
        fn_plot_cluster_hist(cl_id_trials, cluster_mat_trials, order_trials, r_mat_trials);
        
        %colorbar
        if i_condition==1
            axes('position',[position_x1(1+subplot_shift1 + subplot_shift2)+0.13 position_y1(5)-0.05 panel_width1/3 panel_height1]);
            c=colorbar;
            set(c,'Location','southoutside');
            axis off;
            box off;
        end
        
        
        axes('position',[position_x1(1+subplot_shift1 + subplot_shift2) position_y1(1) panel_width1 panel_height1]);
        PV_reordered= PV_current(order_cells,order_trials);
        imagesc(PV_reordered,[0,2]);
        colormap(jet);
        xlabel('Trials','FontSize',8);
        ylabel('Cells','FontSize',8);
        title('P.V. clustered','FontSize',8);
        
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