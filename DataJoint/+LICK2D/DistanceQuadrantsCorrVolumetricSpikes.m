%{
# Pairwise correlation as a function of distance
-> EXP2.SessionEpoch
odd_even_corr_threshold               : double   #
---
distance_corr_2d                     :blob      # mat of average pairwise pearson coeff of cells, binned according lateral X axial distance
distance_corr_lateral                     :blob      # binned according lateral X axial distance
distance_corr_axial_inside_column    :blob      # binned according lateral X axial distance
distance_corr_axial_outside_column    :blob      # binned according lateral X axial distance
axial_distance_bins                   :blob      # axial bins
lateral_distance_bins                 :blob      # axial bins 
num_cells_included                    :int      # 
%}


classdef DistanceQuadrantsCorrVolumetricSpikes < dj.Computed
    properties
        keySource = ((EXP2.SessionEpoch  & IMG.ROI & LICK2D.ROILick2DQuadrantsSpikes & IMG.Mesoscope) - EXP2.SessionEpochSomatotopy)&IMG.Volumetric ;
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
            dir_save_fig = [dir_base  '\Lick2D\population\corr_distance_quadrants\'];
            
            psth_quadrants_odd_even_corr_threshold=[-1, 0, 0.25, 0.5, 0.75];
            
            for i_c = 1:1:numel(psth_quadrants_odd_even_corr_threshold)
                rel_roi = (IMG.ROI - IMG.ROIBad) & key & (LICK2D.ROILick2DQuadrantsSpikes & sprintf('psth_quadrants_odd_even_corr>=%.2f',psth_quadrants_odd_even_corr_threshold(i_c)));
                rel_data = LICK2D.ROILick2DQuadrantsSpikes & rel_roi & key;
                key.odd_even_corr_threshold = psth_quadrants_odd_even_corr_threshold(i_c);
                fn_compute_distance_psth_correlation(rel_roi, rel_data, key,self, dir_save_fig);
            end
            
        end
    end
    
end

