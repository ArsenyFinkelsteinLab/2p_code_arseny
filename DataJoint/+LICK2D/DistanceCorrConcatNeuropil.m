%{
# Pairwise correlation as a function of distance
-> EXP2.SessionEpoch
odd_even_corr_threshold               : double   #
---
distance_corr_2d                     :blob      # mat of average pairwise pearson coeff of cells, binned according lateral X axial distance
distance_corr_lateral                :blob      # binned according lateral X axial distance
distance_corr_axial_columns           :blob      # correlation binned according to axial distance, for cells  within columns of different size defined by inner and and outer radius, which is the lateral distance of cells included within a column
column_inner_radius                  :blob      # inner radius of a column, microns. cells at lateral distance smaller than this radius are not included
column_outer_radius                  :blob      # outer radius of a column, microns. cells at lateral distance larger than this radius are not included
axial_distance_bins                  :blob      # axial bins, microns
lateral_distance_bins                :blob      # axial bins, microns
num_cells_included                   :int       #
%}


classdef DistanceCorrConcatNeuropil < dj.Computed
    properties
        %         keySource = ((EXP2.SessionEpoch  & IMG.ROI & LICK2D.ROILick2DContactenatedSpikes - IMG.Mesoscope) - EXP2.SessionEpochSomatotopy)&IMG.Volumetric ;
        keySource = ((EXP2.SessionEpoch  & IMG.ROI & LICK2D.ROILick2DContactenatedNeuropil) - EXP2.SessionEpochSomatotopy)&IMG.Volumetric ;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            close all;
            %Graphics
            %---------------------------------
            figure;
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            
            psth_position_concat_regularreward_odd_even_corr=[-1, 0, 0.25, 0.5];
            
            mesoscope_flag=count(IMG.Mesoscope & key);
            if mesoscope_flag==1
                dir_save_fig = [dir_base  '\Lick2D\population\corr_distance_concat_meso_neuropil\'];
            else
                dir_save_fig = [dir_base  '\Lick2D\population\corr_distance_concat_notmeso_neuropil\'];
                
            end
            
            for i_c = 1:1:numel(psth_position_concat_regularreward_odd_even_corr)
                rel_roi = (IMG.ROI - IMG.ROIBad) & key & (LICK2D.ROILick2DContactenatedNeuropil & sprintf('psth_position_concat_regularreward_odd_even_corr>=%.2f',psth_position_concat_regularreward_odd_even_corr(i_c)));
                rel_roi_xy = IMG.ROIPositionETL & rel_roi;
                rel_data = LICK2D.ROILick2DContactenatedNeuropil & rel_roi & key;
                key.odd_even_corr_threshold = psth_position_concat_regularreward_odd_even_corr(i_c);
                fn_compute_distance_psth_correlation(rel_roi, rel_data, key,self, dir_save_fig, rel_roi_xy, mesoscope_flag);
            end
            
        end
    end
    
end

