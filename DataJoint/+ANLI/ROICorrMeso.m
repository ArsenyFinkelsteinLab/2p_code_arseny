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


classdef ROICorrMeso < dj.Computed
    properties
        keySource = EXP2.SessionEpoch & 'session_epoch_type="spont_only"' & IMG.ROI & IMG.ROISpikes & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            close all
 dir_base =fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  'Mesoscope\Graph_correlation1_remove1PC\'];
            
            minimal_distance =25; %in microns
            corr_threshold =0.15;
            smooth_time =1; %seconds
            remove_PCs=1;
            %
            %             try
            %                 zoom =fetch1(IMG.FOVEpoch & key,'zoom');
            %                 kkk.scanimage_zoom = zoom;
            %                 pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOVEpoch & key, 'fov_x_size');
            %             catch
            %                 pix2dist= fetch1(IMG.Parameters & 'parameter_name="fov_size_microns_z1.1"', 'parameter_value')/fetch1(IMG.FOV & key, 'fov_x_size');
            %             end
            pix2dist=1;
            try
                frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            catch
                frame_rate= fetch1(IMG.FOV & key, 'imaging_frame_rate');
            end
            
            smooth_frames = ceil(smooth_time * frame_rate);
            
            minimal_distance_pixels = minimal_distance/pix2dist; % in pixels
            
            
            
            
            
            
            panel_width1=0.8;
            panel_height1=0.5;
            
            panel_width2=0.15;
            panel_height2=0.15;
            
            horizontal_distance=0.22;
            vertical_distance=0.3;
            
            position_x(1)=0.1;
            position_x(end+1)=position_x(end) + horizontal_distance;
            position_x(end+1)=position_x(end) + horizontal_distance*1.2;
            position_x(end+1)=position_x(end) + horizontal_distance*0.9;
            
            position_y(1)=0.4;
            position_y(end+1)=position_y(end) - vertical_distance;
            position_y(end+1)=position_y(end) - vertical_distance;
            
            
            %             rel =  IMG.ROI & IMG.ROIGood & key & (ANLI.IncludeROI & 'number_of_events>=10');
            rel =  IMG.ROI*IMG.PlaneCoordinates & IMG.ROIGood & key;
            M = fetch(rel,'*');
            M=struct2table(M);

            roi_number_list = M.roi_number;

            %             pozs_x=fetchn(rel,'roi_centroid_x','ORDER BY roi_number')*pix2dist;
            %             pos_y=fetchn(rel,'roi_centroid_y','ORDER BY roi_number')*pix2dist;
            
            
            x = M.roi_centroid_x + M.x_pos_relative;
            y = M.roi_centroid_y + M.y_pos_relative;
            
            
            
            F = fetchn(IMG.ROISpikes & rel & key,'spikes_trace','ORDER BY roi_number');
            F=cell2mat(F);
            
            F=movmean(F,[smooth_frames 0],'omitnan','Endpoints','shrink');
            F = F - mean(F,2);
            
         
            
%             [coeff,score,~, ~, explained] = pca(F,'NumComponents',100);
%             use_pcs=1:1:numel(explained);
%             use_pcs(remove_PCs)=[];
%             Fz_reconst=score(:,use_pcs)*coeff(:,use_pcs)';
            Fz_reconst = F;
            clear F;
          
          
            
            [rho,pval]=corr(Fz_reconst');
            
            key.roi_number_list=roi_number_list;
            key.mat_roi_corr=rho;
            key.mat_roi_corr_pval=pval;
            
            
            
            key.roi_pos_x=x;
            key.roi_pos_y=y;
            
            mat_distance=zeros(size(rho));
            parfor i_r=1:1:numel(roi_number_list)
                dx = x - x(i_r);
                dy = y - y(i_r);
                mat_distance(i_r,:)=(sqrt(dx.^2 + dy.^2))';
            end
                

            key.mat_distance=mat_distance;
            
            
            %             close;
            
            
            %Graphics
            %---------------------------------
            figure;
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
            %             %% Plotting a graph out of correlation Matrix
            %             M=rho;
            %             diagonal_values = M(1:size(M,1)+1:end);
            %
            %             M = M - diag(diag(M)); %setting diagonal values to 0
            %             M(isnan(M))=0;
            %
            %             M(abs(M)<=corr_threshold)=0;
            %             M(mat_distance<=minimal_distance_pixels)=0;
            %
            %             G = graph(M,'upper');
            %             LWidths = 5*abs(G.Edges.Weight)/max(abs(G.Edges.Weight));
            %
            %             axes('position',[position_x(1), position_y(1), panel_width1, panel_height1]);
            %             mean_img_enhanced = fetch1(IMG.Plane & key,'mean_img_enhanced');
            %             x_dim = [0:1:(size(mean_img_enhanced,1)-1)]*pix2dist;
            %             y_dim = [0:1:(size(mean_img_enhanced,2)-1)]*pix2dist;
            %             D = degree(G);
            %             %             if isempty(LWidths)
            %             p = plot(G,'XData',pos_x,'YData',pos_y,'NodeLabel',{},'LineWidth',0.01);
            %             %             else
            %             %                 p = plot(G,'XData',roi_centroid_x,'YData',roi_centroid_y,'NodeLabel',{},'LineWidth',LWidths);
            %             %             end
            %             p.EdgeCData = table2array(G.Edges(:,2));
            %             p.NodeCData = D/max(D);
            %             p.MarkerSize = 5*(D+1)/max(D);
            %
            %             colormap bluewhitered
            %             colorbar
            %
            %             % highlight(p,[1 3])
            %             %             h = plot(G,'Layout','force');
            %             %             layout(h,'force','UseGravity',true)
            %             s=fetch(EXP2.Session & key,'*');
            %             session_epoch_type=fetch1(EXP2.SessionEpochType & key,'session_epoch_type');
            %
            %             title(sprintf('Session %d epoch %d anm %d  %s %s',s.session,  key.session_epoch_number,s.subject_id, s.session_date,session_epoch_type ));
            %             axis xy
            %             set(gca,'YDir','reverse')
            %             axis equal
            %             xlabel('Anterior - Posterior (\mum)');
            %             ylabel('Lateral - Medial (\mum)');
            %             set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, floor(max(x_dim))], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,floor(max(y_dim))],'TickLength',[0.01,0],'TickDir','out','FontSize',12)
            
            
            
            
            
            
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
            
            distance_bins_all=[prctile(all_distance,[0:1:100])];
            distance_bins_positive=[prctile(all_distance_positive,[0:1:100])];
            distance_bins_negative=[prctile(all_distance_negative,[0:1:100])];
            
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
            
            
            axes('position',[position_x(1), position_y(2), panel_width2, panel_height2]);
            hold on
            plot(bins_center_all,r_binned_all,'-k')
            plot(bins_center_all,r_binned_all,'.k')
            ylabel('Correlations (all)');
            ylim([min([0,min(r_binned_all)]),max(r_binned_all)]);
            xlim([0 max(bins_center_all)]);
            xlabel('Distance (\mum)');
            
            axes('position',[position_x(2), position_y(2), panel_width2, panel_height2]);
            hold on
            
            yyaxis right
            ylabel('Correlations (positive)');
            plot(bins_center_positive,r_binned_positive,'-r')
            plot(bins_center_positive,r_binned_positive,'.r')
            xlabel('Distance (\mum)');
            xlim([0 max(bins_center_positive)]);
            
            yyaxis left
            plot(bins_center_negative,r_binned_negative,'-b')
            plot(bins_center_negative,r_binned_negative,'.b')
            ylabel('Correlations (negative)');
            
            
            
            
            %             axes('position',[position_x(3), position_y(2), panel_width2, panel_width2]);
            %             hold on
            %             histogram(D,10);
            %             xlabel('Node degree');
            %             ylabel('Counts');
            
            
%             axes('position',[position_x(4), position_y(2), panel_width2, panel_height2]);
%             plot(1:20,explained(1:20));
%             xlabel('Principal Component #');
%             ylabel('Variance Explained');
%             box off;
            %Saving the graph
            
            
            insert(self, key);
            
            
            dir_save_figure = [dir_current_fig 'anm' num2str(s.subject_id) '\'];
            if isempty(dir(dir_save_figure))
                mkdir (dir_save_figure)
            end
            figure_name_out = [dir_save_figure  's' num2str(s.session ) '_' s.session_date '_epoch' num2str(key.session_epoch_number)];
            eval(['print ', figure_name_out, ' -dtiff  -r500']);
            
            
        end
    end
end

