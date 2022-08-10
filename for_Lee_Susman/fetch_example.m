function fetch_example

rel_session_behav = (EXP2.SessionEpoch & IMG.Mesoscope & 'session_epoch_type="behav_only"');
rel_session_spont = (EXP2.SessionEpoch & IMG.Mesoscope & 'session_epoch_type="spont_only"') - EXP2.SessionEpochSomatotopy;
rel_dff =IMG.ROIdeltaF ;

Sspont=fetch(rel_session_behav);
Sbehav=fetch(rel_session_behav);

% Here I will fetch only spontaneous sessions epochs,
% You can do the same thing for behavioral epochs by replacing Sspont with Sbehav in the code below:


%% Example 1: Fetching large datasets, by partitioning into chunks
F_all_sessions=[];
for i_k = 1:1:numel(Sspont)
    key=Sspont(i_k);
    % Because this can be very large matrices, I am fetching it by chunks of 500 neurons at a time
    roi_list=fetchn(rel_dff & key,'roi_number','ORDER BY roi_number');
    num_rois=numel(roi_list);
    chunk_size=500;
    counter=0;
    F=[];
    for i_chunk=1:chunk_size:roi_list(end)
        roi_interval = [i_chunk, i_chunk+chunk_size];
        temp_F=cell2mat(fetchn(rel_dff & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
        temp_count=(counter+1):1: (counter + size(temp_F,1));
        F(temp_count,:)=temp_F;
        counter = counter + size(temp_F,1);
    end
    F_all_sessions{i_k} =F;
end



%% Example 2: Good for fetching relatively small data sets
%% (which is NOT the case for mesoscpe recordings) so better use Example 1 above for large data:
F_all_sessions=[];
for i_k = 1:1:numel(Sspont)
    key=Sspont(i_k);
    %This can be very slow if you have many neurons as in mesoscoperecordings
    F_all_sessions{i_k}=cell2mat(fetchn(rel_dff & key, 'dff_trace','ORDER BY roi_number'));
end




