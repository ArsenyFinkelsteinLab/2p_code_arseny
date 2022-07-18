dir_save = 'C:\Users\scanimage\Google Drive\WORK\Shared_files\Lee_Susman\mesoscope_data\';
key.subject_id = 464725;
key.session = 8;
filename = ['data_subject' num2str(key.subject_id) '_session_' num2str(key.session) '.mat'];

imaging_frame_rate = fetch1(IMG.FOVEpoch & key,'imaging_frame_rate','LIMIT 1');

rel= IMG.ROI*IMG.ROIBrainArea*IMG.PlaneCoordinates  & IMG.ROIGood & (EXP2.SessionEpoch & IMG.Mesoscope & key);

%% Spontaneous dff
rel_trace =IMG.ROIdeltaF & rel & 'session_epoch_type="spont_only"' & 'session_epoch_number=1';
dff_spont=cell2mat(fetchn(rel_trace, 'dff_trace','ORDER BY roi_number'));

%% Behavioral dff
rel_trace =IMG.ROIdeltaF & rel & 'session_epoch_type="behav_only"';
dff_behav=cell2mat(fetchn(rel_trace, 'dff_trace','ORDER BY roi_number'));



%% Anatomical Coordinates in microns
R=fetch(rel,'roi_centroid_x','roi_centroid_y','x_pos_relative','y_pos_relative','brain_area');
x = [R.roi_centroid_x] + [R.x_pos_relative];
y = [R.roi_centroid_y] + [R.y_pos_relative];
x=x/0.75;
y=y/0.5;

Data.subject_id=key.subject_id;
Data.session = key.session;
Data.dff_spont=dff_spont;
Data.dff_behav=dff_behav;
Data.cell_x=x;
Data.cell_y=y;
Data.cell_y=y;
Data.brain_area={R.brain_area};
Data.imaging_frame_rate = imaging_frame_rate;
Data.Comment = 'dff_spont & dff_behav are NeuronsXFrames matrix of neural activity (deltaF/F, calcium imaging) of the same cells imaged during spontaneous and behavioral session; imaging_frame_rate in Hz; cell_x & cell_y represent antatomical coordinates of each neuron  in microns';


save([dir_save filename],'Data')

