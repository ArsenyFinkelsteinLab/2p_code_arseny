%{
# Taking most responsive neurons
-> EXP2.SessionEpoch
---
mat_response_mean       : longblob                # (pixels)
mat_distance       : longblob                # (pixels)
mat_response_pval       : longblob                # (pixels)

roi_num_list          : blob                # (pixels)
photostim_group_num_list          : blob                # (pixels)


%}


classdef ROIGraph < dj.Imported
    properties
        %         keySource = IMG.PhotostimGroup;
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.FOV;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base =fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_save_figure = [dir_base '\Graph\'];

            p_val_threshold =0.001;
            
            group_num=  fetchn( STIM.ROIResponseDirect & key & 'most_response_p_value<0.001','photostim_group_num','ORDER BY photostim_group_num');
            roi_num=  fetchn( STIM.ROIResponseDirect & key,'roi_number','ORDER BY photostim_group_num');
            roi_centroid_x=  fetchn( STIM.ROIResponseDirect*IMG.ROI & key,'roi_centroid_x','ORDER BY photostim_group_num');
            roi_centroid_y=  fetchn( STIM.ROIResponseDirect*IMG.ROI & key,'roi_centroid_y','ORDER BY photostim_group_num');

            
            
            k1=key;
            tic
            F=struct2table(fetch( STIM.ROIResponse50 & (IMG.PhotostimGroup & (STIM.ROIResponseDirect & key)),'*'));
            toc
            for i_g = 1:1:numel(group_num)
                %                 k1.photostim_group_num = group_num(i_g);
                for i_r  = 1:1:numel(group_num)
                    %                     k1.roi_number = roi_num(i_r);
                    F_selected=F(F.photostim_group_num ==group_num(i_g) & F.roi_number == roi_num(i_r),:);
                    
                    key.mat_response_mean(i_g,i_r)=F_selected.response_mean;
                    key.mat_distance(i_g,i_r)=F_selected.response_distance_pixels;
                    key.mat_response_pval(i_g,i_r)=F_selected.response_p_value;
                    %                     key.mat_response_mean(i_g,i_r)= fetch1(STIM.ROIResponse50 & k1,'response_mean');
                    %                     key.mat_distance(i_g,i_r)= fetch1(STIM.ROIResponse50 & k1,'response_distance_pixels');
                    %                     key.mat_response_pval(i_g,i_r)= fetch1(STIM.ROIResponse50 & k1,'response_p_value');
                    
                end
                
            end
            key.roi_num_list = group_num;
            key.photostim_group_num_list = roi_num;
            insert(self,key);
            
            s=fetch(EXP2.Session & key,'*');
            
            % Creating a Graph
            M=key.mat_response_mean;
            M = M - diag(diag(M)); %setting diagonal values to 0
            
            M(key.mat_response_pval>p_val_threshold)=0;
            G = digraph(M);
            D = outdegree(G);
            p = plot(G,'XData',roi_centroid_x,'YData',roi_centroid_y,'MarkerSize',5);
p.NodeCData = D;
colormap jet
colorbar
%             h = plot(G,'Layout','force');
%             layout(h,'force','UseGravity',true)
            
            title(sprintf('Session %d epoch %d \n anm %d  %s',s.session,  key.session_epoch_number,s.subject_id, s.session_date ));
            axis off;
            box off;
            
            %Saving the graph
            
            dir_current_figure = [dir_save_figure 'anm' num2str(s.subject_id) '\'];
            if isempty(dir(dir_current_figure))
                mkdir (dir_current_figure)
            end
            figure_name_out = [dir_current_figure  's' num2str(s.session ) '_' s.session_date '_epoch' num2str(key.session_epoch_number)];
            eval(['print ', figure_name_out, ' -dtiff  -r200']);
            
            clf;
            
        end
    end
end