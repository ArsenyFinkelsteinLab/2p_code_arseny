function fn_pv_corr_ensemble(k, date, dir_save_figure, clustering_option_name, rel, flag_update_cluster_group_table)


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



k.session_date=date;

key=fetch(EXP.Session & k);

b=fetch(EXP.BehaviorTrial & (EXP.Session & key) & 'early_lick="no early"','*','ORDER BY trial');
b=struct2table(b);
trials(1).tr = find(contains(b.trial_instruction,'left') & contains(b.outcome,'hit') & contains(b.early_lick,'no early'));
trials(1).lick_direction='left';
trials(2).tr = find(contains(b.trial_instruction,'right') & contains(b.outcome,'hit') & contains(b.early_lick,'no early'));
trials(2).lick_direction='right';

% trials(1).tr = find( contains(b.early_lick,'no early'));
% trials(1).lick_direction='all';

% trials(1).tr = find( contains(b.early_lick,'no early') & contains(b.outcome,'hit'));
% trials(1).lick_direction='hit';
% trials(2).tr = find(contains(b.early_lick,'no early') & contains(b.outcome,'miss'));
% trials(2).lick_direction='miss';

% trials(1).tr = find( contains(b.early_lick,'no early') & ~contains(b.outcome,'ignore'));
% trials(1).lick_direction='all';


% trials(1).tr = find(([contains(b.trial_instruction,'left') & contains(b.outcome,'hit')] | [contains(b.trial_instruction,'right') & contains(b.outcome,'miss')])  & contains(b.early_lick,'no early') );
% trials(1).lick_direction='left';
% trials(2).tr = find(([contains(b.trial_instruction,'right') & contains(b.outcome,'hit')] | [contains(b.trial_instruction,'left') & contains(b.outcome,'miss')])  & contains(b.early_lick,'no early') );
% trials(2).lick_direction='right';


PV =[];


%     current_trials=trials(i_condition).tr;
current_trials=[b.trial];
for iTr=1:1:numel(current_trials)
    key.trial = current_trials(iTr);
    CTr = fetch(ANLI.FPSTHtrial & rel & key,'*', 'ORDER BY roi_number');
    CTr=struct2table(CTr);
    t=CTr.psth_timestamps(1,:);
    time_sample_end=  CTr.time_sample_end(1);
    t_delay_idx= t>=time_sample_end & t<0;
    t_response_idx= t>=0 & t<2;
    psth_trial =CTr.psth_trial;
    PV.epoch{1}(:,iTr)= mean(psth_trial(:,t_delay_idx),2);
    PV.epoch{2}(:,iTr)= mean(psth_trial(:,t_response_idx),2);
end


for i_condition = 1:numel(trials)
    PV_current=[];
    r =[];
    r_mat_trials=[];
    r_mat_cells=[];
    
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
        
        
        % correlation matrix of the PV across trials
        PV_current =PV.epoch{i_epoch};
        %         mean_response = mean(PV_current,2);
        %         for i_c=1:1:size(PV_current,1)
        %              PV_current(i_c,:)=       PV_current(i_c,:)>=mean_response(i_c); %binarizing
        %         end
        %         PV_current= rescale(PV_current,'InputMin',0,'InputMax',1);
        
        
        %     mean_response = mean(PV_current,2);
        for i_c=1:1:size(PV_current,1)
            z=zscore( PV_current(i_c,:));
            PV_current(i_c,:)=       z>1; %binarizing
            
            %              PV_current(i_c,:)=       PV_current(i_c,:)>=mean_response(i_c); %binarizing
        end
        
        
        PV_current= PV_current(:,trials(i_condition).tr);
        
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
        
        
        %                 mean_response = mean(PV_current,2);
        %         for i_c=1:1:size(PV_current,1)
        %              PV_current(i_c,:)=       PV_current(i_c,:)>=mean_response(i_c); %binarizing
        %         end
        
        axes('position',[position_x1(1+subplot_shift1 + subplot_shift2) position_y1(1) panel_width1 panel_height1]);
        PV_reordered= PV_current(order_cells,order_trials);
        imagesc(PV_reordered,[0 2]);
        colormap(jet);
        xlabel('Trials','FontSize',8);
        ylabel('Cells','FontSize',8);
        title('P.V. clustered','FontSize',8);
        
        
        %         % Cell by Trials  PV matrix (not correlation)
        %         PVzscore= rescale(PV.epoch{i_epoch},'InputMin',0,'InputMax',1);
        
        
        %         if size (r_mat,1)<500
        %             set(gca,'xtick',[1,100:100:size(r_mat,1)],'ytick',100:100:size(r_mat,1))
        %         elseif size(r_mat,1)>500 && size (r_mat,1)<=1000
        %             set(gca,'xtick',[1,200:200:size(r_mat,1)],'ytick',200:200:size(r_mat,1))
        %         elseif size(r_mat,1)>1000
        %             set(gca,'xtick',[1,500:500:size(r_mat,1)],'ytick',500:500:size(r_mat,1))
        %         end
        %
        % %         colorbar
        %                 % cluster pairwise distance of Cell by Trials  PV matrix (not correlation)
        %         axes('position',[position_x1(1+subplot_shift1 + subplot_shift2) position_y1(5) panel_width1 panel_height1]);
        %         [cl_id2, cluster_mat2, order2]=fn_ClusterPVtrials(PVzscore);
        %         fn_plot_cluster_mat(cluster_mat2);
        % %         colorbar
        %
        %
        %         r_trials=corr(PV.epoch{i_epoch}, 'rows', 'pairwise');
        %         [~, ~, order_trials]=fn_ClusterPVtrials(r_trials);
        %
        %
        %
        %         axes('position',[position_x1(1+subplot_shift1 + subplot_shift2) position_y1(4) panel_width1 panel_height1]);
        %
        %         PV_reordered= PVzscore(order,order_trials);
        %         imagesc(PV_reordered);
        %         colormap(jet);
        %       xlabel('Trials','FontSize',8);
        %                 ylabel('Neurons','FontSize',8);
        %         title('P.V.','FontSize',8);
        %
        
        
        if flag_update_cluster_group_table~=0
            
            
            % updating the cluster Table
            key_TrialCluster=[];
            key_TrialCluster = fetch(EXP.Session &key);
            key_TrialCluster.clustering_option_name = clustering_option_name;
            key_TrialCluster.trial_epoch_name = PV.epoch_label{i_epoch};
            key_TrialCluster = repmat(key_TrialCluster,numel(current_trials),1);
            count =hist(cl_id, 1:max(cl_id));
            [~,idx_sort_count] = sort(count,'descend');
            
            
            for j_tr=1:1:numel(current_trials)
                key_TrialCluster(j_tr).trial = current_trials(j_tr);
                key_TrialCluster(j_tr).trial_cluster_id = cl_id(j_tr);
                key_TrialCluster(j_tr).trial_cluster_group = find(idx_sort_count==cl_id(j_tr)); % group 1 - largest cluster, group 2 - second largest cluster etc.
            end
            
            %deleting entries in case of duplicates to be able to overwrite
            rel=fetch(ANLI.TrialCluster & key_TrialCluster);
            if ~isempty(rel)
                del(ANLI.TrialCluster&key_TrialCluster);
            end
            insert(ANLI.TrialCluster,key_TrialCluster);
        end
    end
end

if isempty(dir(dir_save_figure))
    mkdir (dir_save_figure)
end

filename=['pv_' date];
figure_name_out=[ dir_save_figure filename];
eval(['print ', figure_name_out, ' -dtiff  -r600']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);

clf;
end