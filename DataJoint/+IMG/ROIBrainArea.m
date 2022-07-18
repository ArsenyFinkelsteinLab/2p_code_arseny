%{
# ROI (Region of interest - e.g. cells), parcellation according to Allen Brain atlas
-> IMG.ROI
-> LAB.BrainArea
---
%}

classdef ROIBrainArea < dj.Imported
    properties
        keySource = EXP2.Session & IMG.Bregma & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            %             clf
            
            R=fetch (IMG.ROI & key, 'roi_centroid_x','roi_centroid_y', 'ORDER BY roi_number');
            x_all= [R.roi_centroid_x]';
            y_all= [R.roi_centroid_y]';
            key_ROI= rmfield(R,'roi_centroid_x');
            key_ROI= rmfield(key_ROI,'roi_centroid_y');
            
            
            x_pos_relative=fetchn(IMG.ROI*IMG.PlaneCoordinates& key ,'x_pos_relative','ORDER BY roi_number');
            y_pos_relative=fetchn(IMG.ROI*IMG.PlaneCoordinates& key,'y_pos_relative','ORDER BY roi_number');
            
            x_all = x_all + x_pos_relative;
            y_all = y_all + y_pos_relative;
            x_all = x_all/0.75;
            y_all = y_all/0.5;
            
            
            % aligning relative to bregma
            bregma_x_mm=1000*fetchn(IMG.Bregma & key,'bregma_x_cm');
            bregma_y_mm=1000*fetchn(IMG.Bregma & key,'bregma_y_cm');
            x_all_max= max(x_all);
            y_all_min= min(y_all);
            
            x_all=x_all-[x_all_max - bregma_x_mm]; % anterior posterior
            y_all=y_all-y_all_min+bregma_y_mm; % medial lateral
            
            
            
            %% PLOT ALLEN MAP
            allen2mm=1000*3.2/160;
            allenDorsalMapSM_Musalletal2019 = load('allenDorsalMapSM_Musalletal2019.mat');
            edgeOutline = allenDorsalMapSM_Musalletal2019.dorsalMaps.edgeOutline;
            labels = allenDorsalMapSM_Musalletal2019.dorsalMaps.labels;
            
            relevant_brain_area = fetchn(LAB.BrainArea,'brain_area');
            idx_relevant_areas=(ismember(labels,relevant_brain_area));
            edgeOutline=edgeOutline(idx_relevant_areas);
            labels=labels(idx_relevant_areas);
            
            bregma_x_allen = allenDorsalMapSM_Musalletal2019.dorsalMaps.bregmaScaled(2);
            bregma_y_allen = allenDorsalMapSM_Musalletal2019.dorsalMaps.bregmaScaled(1);
            
            
            numberROI = size(R,1);
            
            
            roi_brain_area=cell(numberROI,1);
            for i_a = 1:1:numel(edgeOutline)
                hold on
                xxx_area_edges = -1*([edgeOutline{i_a}(:,1)]-bregma_x_allen);
                yyy_area_edges= [edgeOutline{i_a}(:,2)]-bregma_y_allen;
                xxx_area_edges=xxx_area_edges*allen2mm;
                yyy_area_edges=yyy_area_edges*allen2mm;
                
                in = inpolygon( x_all , y_all , xxx_area_edges , yyy_area_edges ) ;
                roi_brain_area(in)=labels(i_a);
%                 hold on
%                 plot(xxx_area_edges, yyy_area_edges,'.','Color', [0 0 0], 'MarkerSize', 5)
                
            end
            
%             plot(x_all,y_all,'.');
            
            for i_r = 1:1:numberROI
                
                if isempty(roi_brain_area{i_r}) && i_r~=1
                    roi_brain_area(i_r)=roi_brain_area(i_r-1);
                end
                
                if isempty(roi_brain_area{i_r}) && i_r==1
                    roi_brain_area(i_r) = roi_brain_area( find(~cellfun(@isempty,roi_brain_area),1));
                end
                
                key_ROI(i_r).brain_area=roi_brain_area{i_r};
                
            end
            
            insert(self,key_ROI);
            
            
        end
        
    end
end
