%{
# Taking most responsive neurons
-> EXP2.SessionEpoch
---
mat_response_mean        : longblob                # (pixels)
mat_distance             : longblob                # (pixels)
mat_response_pval        : longblob                # (pixels)
roi_num_list             : blob                # (pixels)
photostim_group_num_list          : blob                # (pixels)


%}


classdef ROIGraphAll < dj.Imported
    properties
        %         keySource = IMG.PhotostimGroup;
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.FOV ;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            dir_base =fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_save_figure = [dir_base '\GraphAll\'];       
            
            p_val_threshold =0.01;
            minimal_distance =30; %in microns
            
            try
                zoom =fetch1(IMG.FOVEpoch & key,'zoom');
                kkk.scanimage_zoom = zoom;
                pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');
            catch
                pix2dist= fetch1(IMG.Parameters & 'parameter_name="fov_size_microns_z1.1"', 'parameter_value')/fetch1(IMG.FOV & key, 'fov_x_size');
            end
            minimal_distance = minimal_distance/pix2dist; % in pixels
            
            group_num=  fetchn( STIM.ROIResponseDirect & key & 'response_p_value<0.01','photostim_group_num','ORDER BY photostim_group_num');
            roi_num=  fetchn( IMG.ROI & key ,'roi_number','ORDER BY roi_number');
            group_roi_num=  fetchn( STIM.ROIResponseDirect & key & 'response_p_value<0.01','roi_number','ORDER BY photostim_group_num');
            
            roi_num_good = fetchn( IMG.ROIGood & key,'roi_number','ORDER BY roi_number');
            
            [group_roi_num, idxx,idxy ] = unique(group_roi_num,'stable');
            group_num = group_num(idxx);
            
            roi_centroid_x=  fetchn( IMG.ROI & IMG.ROIGood & key,'roi_centroid_x','ORDER BY roi_number')*pix2dist;
            roi_centroid_y=  fetchn(  IMG.ROI & IMG.ROIGood & key,'roi_centroid_y','ORDER BY roi_number')*pix2dist;
            
            
            panel_width=0.8;
            panel_height=0.8;
            horizontal_distance=0.7;
            vertical_distance=0.7;
            
            position_x(1)=0.1;
            position_x(end+1)=position_x(end) + horizontal_distance;
            
            position_y(1)=0.15;
            position_y(end+1)=position_y(end) - vertical_distance;
            
            
            
            k1=key;
            tic
            F=(fetch( STIM.ROIResponse & key & sprintf('response_distance_pixels>%.2f', minimal_distance) &  sprintf('response_p_value<=%.5f', p_val_threshold),'*'));
            if isempty(F)
                return
            end
            F=struct2table(F)
            toc
%             for i_g = 1:1:numel(group_num)
%                 %                 k1.photostim_group_num = group_num(i_g);
%                 for i_r  = 1:1:numel(roi_num)
%                     %                     k1.roi_number = roi_num(i_r);
%                     F_selected=F(F.photostim_group_num ==group_num(i_g) & F.roi_number == roi_num(i_r),:);
%                     
%                     key.mat_response_mean(i_g,i_r)=F_selected.response_mean;
%                     key.mat_distance(i_g,i_r)=F_selected.response_distance_pixels;
%                     key.mat_response_pval(i_g,i_r)=F_selected.response_p_value;
%                     %                     key.mat_response_mean(i_g,i_r)= fetch1(STIM.ROIResponse50 & k1,'response_mean');
%                     %                     key.mat_distance(i_g,i_r)= fetch1(STIM.ROIResponse50 & k1,'response_distance_pixels');
%                     %                     key.mat_response_pval(i_g,i_r)= fetch1(STIM.ROIResponse50 & k1,'response_p_value');
%                     
%                 end
%                 
%             end
%             key.roi_num_list = group_num;
%             key.photostim_group_num_list = roi_num;
%             insert(self,key);
            
            close;
            
            
            %Graphics
            %---------------------------------
            figure;
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
            
            s=fetch(EXP2.Session & key,'*');
            
            % Creating a Graph
            %             M=key.mat_response_mean;
            
%             for i_r  = 1:1:numel(roi_num)
%                 [~,idx_roi]=find(group_roi_num==roi_num(i_r));
%                 if    isempty(idx_roi)
%                     M(i_r,1:numel(roi_num))=0;
%                     Mpval(i_r,1:numel(roi_num))=1;
%                     Mdistance(i_r,1:numel(roi_num))=0;
%                     
%                 else
%                     M(i_r,1:numel(roi_num))=key.mat_response_mean(idx_roi,:);
%                     Mpval (i_r,1:numel(roi_num))=   key.mat_response_pval(idx_roi,:);
%                     Mdistance (i_r,1:numel(roi_num))=   key.mat_distance(idx_roi,:);
%                     
%                 end
%             end
M=zeros(numel(roi_num));
Mdistance=zeros(numel(roi_num));
Mpval=zeros(numel(roi_num))+1;
for i_r  = 1:1:numel(roi_num)
    [idx_roi]=find(group_roi_num==roi_num(i_r));
    if ~   isempty(idx_roi)
     %i_r
        
        F_selected=F(F.photostim_group_num ==group_num(idx_roi),:);
        if isempty(F_selected)
            M(i_r,1:numel(roi_num))=0;
            Mpval(i_r,1:numel(roi_num))=1;
            Mdistance(i_r,1:numel(roi_num))=0;
        else
            
            M(i_r,F_selected.roi_number')=F_selected.response_mean';
            Mpval (i_r,F_selected.roi_number')=   F_selected.response_p_value';
            Mdistance (i_r,F_selected.roi_number') =   F_selected.response_distance_pixels';
            
        end
    end
end
            
M=M(roi_num_good,roi_num_good);
     Mpval=Mpval(roi_num_good,roi_num_good);
            Mdistance=Mdistance(roi_num_good,roi_num_good);

            diagonal_values = M(1:size(M,1)+1:end);
            
            M = M - diag(diag(M)); %setting diagonal values to 0
%             M(Mpval>p_val_threshold)=0;
%             M(Mdistance<=minimal_distance)=0;
            
            G = digraph(M);
            LWidths = 5*abs(G.Edges.Weight)/max(abs(G.Edges.Weight));
            
            axes('position',[position_x(1), position_y(1), panel_width, panel_height]);
            mean_img_enhanced = fetch1(IMG.Plane & key & 'plane_num=1','mean_img_enhanced');
            x_dim = [0:1:(size(mean_img_enhanced,1)-1)]*pix2dist;
            y_dim = [0:1:(size(mean_img_enhanced,2)-1)]*pix2dist;
            
            % imagesc(mean_img_enhanced)
            % colormap(gray)
            % hold on;
            % axis xy
            %   set(gca,'YDir','reverse')
            
            
            D = outdegree(G);
            Din = indegree(G);

            %             if isempty(LWidths)
            p = plot(G,'XData',roi_centroid_x,'YData',roi_centroid_y,'NodeLabel',{});
            %             else
            %                 p = plot(G,'XData',roi_centroid_x,'YData',roi_centroid_y,'NodeLabel',{},'LineWidth',LWidths);
            %             end
            p.EdgeCData = table2array(G.Edges(:,2));
%             p.NodeCData = D/1000;
%              p.NodeCData = [0 0 0];

            p.MarkerSize = D+2;
            
            colormap bluewhitered
            h = colorbar;
            ylabel(h, '\Delta activity')
            % highlight(p,[1 3])
            %             h = plot(G,'Layout','force');
            %             layout(h,'force','UseGravity',true)
            
            title(sprintf('Session %d epoch %d \n anm %d  %s',s.session,  key.session_epoch_number,s.subject_id, s.session_date ));
            %             axis off;
            %             box off;
            axis xy
            set(gca,'YDir','reverse')
            axis equal
            xlabel('Anterior - Posterior (\mum)');
            ylabel('Lateral - Medial (\mum)');
            set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, 800], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,800],'TickLength',[0.01,0],'TickDir','out','FontSize',12)
            
            
            
            %             axes('position',[position_x(1), position_y(2), panel_width, panel_height]);
            %             D = indegree(G);
            %             %             if isempty(LWidths)
            %             p = plot(G,'XData',roi_centroid_x,'YData',roi_centroid_y,'NodeLabel',{});
            %             %             else
            %             %                 p = plot(G,'XData',roi_centroid_x,'YData',roi_centroid_y,'NodeLabel',{},'LineWidth',LWidths);
            %             %             end
            %             p.EdgeCData = table2array(G.Edges(:,2));
            %             p.NodeCData = diagonal_values;
            %             p.MarkerSize = D+1;
            %
            %             colormap bluewhitered
            %             colorbar
            %
            %             % highlight(p,[1 3])
            %             %             h = plot(G,'Layout','force');
            %             %             layout(h,'force','UseGravity',true)
            %
            %             title(sprintf('Session %d epoch %d \n anm %d  %s',s.session,  key.session_epoch_number,s.subject_id, s.session_date ));
            %             axis off;
            %             box off;
            %             axis xy;
            
            %Saving the graph
            
            dir_current_figure = [dir_save_figure 'anm' num2str(s.subject_id) '\'];
            if isempty(dir(dir_current_figure))
                mkdir (dir_current_figure)
            end
            figure_name_out = [dir_current_figure  's' num2str(s.session ) '_' s.session_date '_epoch' num2str(key.session_epoch_number)];
            eval(['print ', figure_name_out, ' -dtiff  -r500']);
            
            
        end
    end
end