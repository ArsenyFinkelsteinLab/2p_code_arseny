function visualizing_neur_traces()

dir_base =fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_save_figure = [dir_base '\example_traces\'];


key.subject_id = 464724;
key.session = 2;
key.session_epoch_number = 2;

rel_roi = (IMG.ROI-IMG.ROIBad) & key;
rel_data = IMG.ROIdeltaF;
roi_list=fetchn(rel_roi,'roi_number','ORDER BY roi_number');
chunk_size=500;
for i_chunk=1:chunk_size:numel(roi_list)
    roi_interval = [i_chunk, i_chunk+chunk_size];
    if roi_interval(end)>numel(roi_list)
        roi_interval(end) = numel(roi_list)+1;
    end
    try
    temp_Fall=cell2mat(fetchn(rel_data & rel_roi &  key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
    catch
            temp_Fall=cell2mat(fetchn(rel_data & rel_roi & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'spikes_trace','ORDER BY roi_number'));
    end
    temp_roi_num=fetchn(rel_roi & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'roi_number','ORDER BY roi_number');
    Fall(temp_roi_num,:)=temp_Fall;
end

imaging_frame_rate = fetch1(IMG.FOVEpoch & key,'imaging_frame_rate');

close all
time_limit = [1400,2400]; %seconds
start_cell = 11;
num_cell_2plot=20
hold on
time=(1:1:size(Fall,2))/imaging_frame_rate;
for i=start_cell:1:(num_cell_2plot+start_cell-1)
    a=Fall(i,:);
    a=rescale(a);
    plot(time,a+(i+0.5),'-k','LineWidth',0.5)
    box off
end
xlim(time_limit)
set(gca,'XtickLabel',[],'Ytick',[],'YtickLabel',[]);

dir_current_figure = [dir_save_figure];
if isempty(dir(dir_current_figure))
    mkdir (dir_current_figure)
end
figure_name_out =[ dir_current_figure 'example_trace'];
eval(['print ', figure_name_out, ' -dtiff  -r500']);
eval(['print ', figure_name_out, ' -painters -dpdf -cmyk -r500']);

