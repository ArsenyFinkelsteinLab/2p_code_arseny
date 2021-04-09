%{
# Pairwise correlation as a function of distance
-> EXP2.SessionEpoch
%}


classdef VisualizingNeurTraces < dj.Computed
    properties
        keySource = ((EXP2.SessionEpoch& IMG.ROIdeltaF) - EXP2.SessionEpochSomatotopy)& IMG.PlaneCoordinates & IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
                        close all

            
            rel_data1 = IMG.ROIdeltaF - IMG.ROIBad;
            rel_data2 = IMG.ROIdeltaFNeuropilSubtr - IMG.ROIBad;
            rel_data3 = IMG.ROISpikes - IMG.ROIBad;
            rel_data4 = IMG.ROIdeltaFNeuropil - IMG.ROIBad;

            roi_list=fetchn(rel_data1 &key,'roi_number','ORDER BY roi_number');
            chunk_size=500;
            for i_chunk=1:chunk_size: 1000 %numel(roi_list)
                roi_interval = [i_chunk, i_chunk+chunk_size];
                if roi_interval(end)>numel(roi_list)
                    roi_interval(end) = numel(roi_list)+1;
                end
                temp_roi_num=fetchn(rel_data1 & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'roi_number','ORDER BY roi_number');
                
                temp_Fall=cell2mat(fetchn(rel_data1 & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
                F1(temp_roi_num,:)=temp_Fall;
                
                temp_Fall=cell2mat(fetchn(rel_data2 & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
                F2(temp_roi_num,:)=temp_Fall;
                
                temp_Fall=cell2mat(fetchn(rel_data3 & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'spikes_trace','ORDER BY roi_number'));
                F3(temp_roi_num,:)=temp_Fall;
                
                temp_Fall=cell2mat(fetchn(rel_data4 & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
                F4(temp_roi_num,:)=temp_Fall;
            end
            
            num=20
            hold on
            time=1:1:size(F1(:,1:10000),2);
            counter=0;
            for i=500:1:num+500
                counter=counter+1;
                
                a=F4(i,1:10000);
                a=rescale(a);
                plot(time,a+(counter+0.5),'-k','LineWidth',0.5)

                
                a=F1(i,1:10000);
                a=rescale(a);
                plot(time,a+(counter+0.5),'-g','LineWidth',0.5)
                
                a=F2(i,1:10000);
                a=rescale(a);
                plot(time,a+(counter+0.5),'-b','LineWidth',0.5)
                
                a=F3(i,1:10000);
                a=rescale(a);
                plot(time,a+(counter+0.5),'-r','LineWidth',0.5)
                
                 
                box off
            end
        end
    end
end
