%{
# ROI responses to each photostim group
-> EXP2.SessionEpoch
---
mat_roi_corr                : longblob               # pearson coeff
mat_roi_corr_pval                : longblob               # signif of pearson coeff
mat_distance                : longblob               # pixels

roi_number_list            : longblob                # list of ROIs used
roi_pos_x            : longblob                # pixels
roi_pos_y            : longblob                # pixels

%}


classdef ROICorr < dj.Computed
    properties
        keySource = EXP2.SessionEpoch & IMG.ROI & IMG.ROISpikes;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            close all
            dir_base =fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Graph_correlation\'];
            
            minimal_distance =25; %in microns
            corr_threshold =0.15;
            smooth_time =2; %seconds
            
            try
                zoom =fetch1(IMG.FOVEpoch & key,'zoom');
                kkk.scanimage_zoom = zoom;
                pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOVEpoch & key, 'fov_x_size');
            catch
                pix2dist= fetch1(IMG.Parameters & 'parameter_name="fov_size_microns_z1.1"', 'parameter_value')/fetch1(IMG.FOV & key, 'fov_x_size');
            end
            
            try
                frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            catch
                frame_rate= fetch1(IMG.FOV & key, 'imaging_frame_rate');
            end
            
            smooth_frames = ceil(smooth_time * frame_rate);
            
            minimal_distance_pixels = minimal_distance/pix2dist; % in pixels
            
            
            
            
            
            
            panel_width=0.8;
            panel_height=0.5;
            horizontal_distance=0.3;
            vertical_distance=0.3;
            
            position_x(1)=0.1;
            position_x(end+1)=position_x(end) + horizontal_distance;
            position_x(end+1)=position_x(end) + horizontal_distance;
            
            position_y(1)=0.4;
            position_y(end+1)=position_y(end) - vertical_distance;
            
            roi_number_list=fetchn(IMG.ROI & IMG.ROIGood & key,'roi_number','ORDER BY roi_number');
            pos_x=fetchn(IMG.ROI & IMG.ROIGood & key,'roi_centroid_x','ORDER BY roi_number')*pix2dist;
            pos_y=fetchn(IMG.ROI & IMG.ROIGood & key,'roi_centroid_y','ORDER BY roi_number')*pix2dist;
            
            F = fetchn((IMG.ROISpikes & key) & IMG.ROIGood ,'spikes_trace','ORDER BY roi_number');
            F=cell2mat(F);
            for i = 1:1:size(F,1)
                f=F(i,:);
                f=smooth(f,smooth_frames);
                %                 f=rescale(f);
                F(i,:)=f';
                %                 moving_baseline=movmin(f,20);
                
                %                 f=F(i,:);
                %                 moving_baseline=movmin(f,6000);
                %                 dff=(f-moving_baseline)./moving_baseline;
                %                 F(i,:)=smooth(dff,smooth_frames);
            end
            %             F=zscore(F,[],2);
            F=F(:,smooth_frames:end-smooth_frames);
            %             meanF=rescale(mean(F));
            %              meanF=zscore(mean(F));
            meanF=mean(F);
            for i = 1:1:size(F,1)
                f=F(i,:);
                
                %                 f=rescale(F(i,:));
                f_sigma=std(f);
                
                %                 f=zscore(F(i,:));
                
                weight=corr(meanF',f');
                f_sub=f-weight*f_sigma*meanF;
                hold on
                plot(f,'-b')
                plot(meanF,'-r')
                plot(f_sub,'-g')
                FbaseSubt(i,:)=f_sub';
            end
            
            %             FbaseSubt = F - mean(F);
            
            [rho,pval]=corr(FbaseSubt');
            
            key.roi_number_list=roi_number_list;
            key.mat_roi_corr=rho;
            key.mat_roi_corr_pval=pval;
            key.roi_pos_x=pos_x;
            key.roi_pos_y=pos_y;
            
            for i_r=1:1:numel(roi_number_list)
                dx = pos_x - pos_x(i_r);
                dy = pos_y - pos_y(i_r);
                mat_distance(i_r,:)=(sqrt(dx.^2 + dy.^2))';
            end
            key.mat_distance=mat_distance;
            
            insert(self, key);
            
            close;
            
            
            %Graphics
            %---------------------------------
            figure;
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
            %% Plotting a graph out of correlation Matrix
            M=rho;
            diagonal_values = M(1:size(M,1)+1:end);
            
            M = M - diag(diag(M)); %setting diagonal values to 0
            M(isnan(M))=0;
            
            M(abs(M)<=corr_threshold)=0;
            M(mat_distance<=minimal_distance_pixels)=0;
            
            G = graph(M,'upper');
            LWidths = 5*abs(G.Edges.Weight)/max(abs(G.Edges.Weight));
            
            axes('position',[position_x(1), position_y(1), panel_width, panel_height]);
            mean_img_enhanced = fetch1(IMG.Plane & key,'mean_img_enhanced');
            x_dim = [0:1:(size(mean_img_enhanced,1)-1)]*pix2dist;
            y_dim = [0:1:(size(mean_img_enhanced,2)-1)]*pix2dist;
            D = degree(G);
            %             if isempty(LWidths)
            p = plot(G,'XData',pos_x,'YData',pos_y,'NodeLabel',{},'LineWidth',0.01);
            %             else
            %                 p = plot(G,'XData',roi_centroid_x,'YData',roi_centroid_y,'NodeLabel',{},'LineWidth',LWidths);
            %             end
            p.EdgeCData = table2array(G.Edges(:,2));
            p.NodeCData = D/max(D);
            p.MarkerSize = 5*(D+1)/max(D);
            
            colormap bluewhitered
            colorbar
            
            % highlight(p,[1 3])
            %             h = plot(G,'Layout','force');
            %             layout(h,'force','UseGravity',true)
            s=fetch(EXP2.Session & key,'*');
            session_epoch_type=fetch1(EXP2.SessionEpochType & key,'session_epoch_type');
            
            title(sprintf('Session %d epoch %d \n anm %d  %s \n %s',s.session,  key.session_epoch_number,s.subject_id, s.session_date,session_epoch_type ));
            axis xy
            set(gca,'YDir','reverse')
            axis equal
            xlabel('Anterior - Posterior (\mum)');
            ylabel('Lateral - Medial (\mum)');
            set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, floor(max(x_dim))], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,floor(max(y_dim))],'TickLength',[0.01,0],'TickDir','out','FontSize',12)
            
            
            
            
            
            
            %% Distance dependence
            rho(isnan(rho))=0;
            temp=logical(tril(rho));
            idx_up_triangle=~temp;
            
            all_corr = rho(idx_up_triangle);
            all_distance = mat_distance(idx_up_triangle)*pix2dist;
            
            idx_positive_r=all_corr>=0;
            all_corr_positive=all_corr(idx_positive_r);
            all_distance_positive=all_distance(idx_positive_r);
            
            idx_negative_r=all_corr<0;
            all_corr_negative=all_corr(idx_negative_r);
            all_distance_negative=all_distance(idx_negative_r);
            
            distance_bins_all=[prctile(all_distance,[0:10:100])];
            distance_bins_positive=[prctile(all_distance_positive,[0:10:100])];
            distance_bins_negative=[prctile(all_distance_negative,[0:10:100])];
            
            for i_d=1:1:numel(distance_bins_positive)-1
                
                idx=all_distance>=(distance_bins_all(i_d)) & all_distance<(distance_bins_all(i_d+1));
                r_binned_all(i_d)=mean(all_corr(idx));
                bins_center_all(i_d) = (distance_bins_all(i_d) + distance_bins_all(i_d+1))/2;
                
                
                idx=all_distance_positive>=(distance_bins_positive(i_d)) & all_distance_positive<(distance_bins_positive(i_d+1));
                r_binned_positive(i_d)=mean(all_corr_positive(idx));
                bins_center_positive(i_d) = (distance_bins_positive(i_d) + distance_bins_positive(i_d+1))/2;
                
                idx=all_distance_negative>=(distance_bins_negative(i_d)) & all_distance_negative<(distance_bins_negative(i_d+1));
                r_binned_negative(i_d)=mean(all_corr_negative(idx));
                bins_center_negative(i_d) = (distance_bins_negative(i_d) + distance_bins_negative(i_d+1))/2;
                
            end
            
            
            axes('position',[position_x(1), position_y(2), panel_width/4, panel_height/4]);
            hold on
            plot(bins_center_all,r_binned_all,'-.b')
            ylabel('Pairwise correlations (all)');
            ylim([min([0,min(r_binned_all)]),max(r_binned_all)]);
            xlim([0 max(bins_center_all)]);
            xlabel('Distance (\mum)');
            
            axes('position',[position_x(2), position_y(2), panel_width/4, panel_height/4]);
            hold on
            
            yyaxis right
            ylabel('Pairwise correlations (positive)');
            plot(bins_center_positive,r_binned_positive,'-.r')
            xlabel('Distance (\mum)');
            xlim([0 max(bins_center_positive)]);
            
            yyaxis left
            plot(bins_center_negative,r_binned_negative,'-.b')
            ylabel('Pairwise correlations (negative)');
            
            
            
            
            axes('position',[position_x(3), position_y(2), panel_width/4, panel_height/4]);
            hold on
            histogram(D,10);
            xlabel('Node degree');
            ylabel('Counts');
            
            
            %Saving the graph
            
            dir_save_figure = [dir_current_fig 'anm' num2str(s.subject_id) '\'];
            if isempty(dir(dir_save_figure))
                mkdir (dir_save_figure)
            end
            figure_name_out = [dir_save_figure  's' num2str(s.session ) '_' s.session_date '_epoch' num2str(key.session_epoch_number)];
            eval(['print ', figure_name_out, ' -dtiff  -r500']);
            
            
        end
    end
end

