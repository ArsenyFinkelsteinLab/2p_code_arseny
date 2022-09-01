function fn_compute_SVD_crossvalid(key, rel_data1, self,  flag_zscore,time_bin, threshold_for_event_vector, threshold_variance_explained, num_components_save)

key.time_bin = time_bin;
try
    imaging_frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
catch
    imaging_frame_rate = fetch1(IMG.FOV & key, 'imaging_frame_rate');
end

roi_list=fetchn(rel_data1 & key,'roi_number','ORDER BY roi_number');
num_rois=numel(roi_list);
chunk_size=500;
counter=0;
for i_chunk=1:chunk_size:roi_list(end)
    roi_interval = [i_chunk, i_chunk+chunk_size];
    try
        temp_F=cell2mat(fetchn(rel_data1 & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
    catch
        temp_F=cell2mat(fetchn(rel_data1 & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'spikes_trace','ORDER BY roi_number'));
    end
    temp_count=(counter+1):1: (counter + size(temp_F,1));
    F(temp_count,:)=temp_F;
    counter = counter + size(temp_F,1);
end

%% binning in time
if time_bin>0
    bin_size_in_frame=ceil(time_bin*imaging_frame_rate);
    
    bins_vector=1:bin_size_in_frame:size(F,2);
    bins_vector=bins_vector(2:1:end);
    for  i= 1:1:numel(bins_vector)
        ix1=(bins_vector(i)-bin_size_in_frame):1:(bins_vector(i)-1);
        F_binned(:,i)=mean(F(:,ix1),2);
    end
else
    F_binned=F;
end


% for cross validation
cv_chunk = 60; %seconds
cv_chunk_in_bins = (cv_chunk*imaging_frame_rate/bin_size_in_frame);

% cv_chunk_vector=unique([1:cv_chunk:size(F_binned,2),size(F_binned,2)]);
cv_chunk_vector=1:cv_chunk:size(F_binned,2);

cv_chunk_vector_odd = cv_chunk_vector(1:2:end);
cv_chunk_vector_even = cv_chunk_vector(2:2:end);
cv_chunk_vector=cv_chunk_vector(2:1:end);

idx_train =[];
for  i= 1:1:min([numel(cv_chunk_vector_odd),numel(cv_chunk_vector_even)])
    idx_train =  [idx_train, cv_chunk_vector_odd(i):1:cv_chunk_vector_even(i)];
end

idx_test = setdiff(1:1:cv_chunk_vector(end),idx_train);

min_length = min(numel(idx_train),numel(idx_test));
idx_train=idx_train(1:1:min_length);
idx_test=idx_test(1:1:min_length);


F_binned = gpuArray(F_binned);

% F_train = gpuArray(F_binned(:,idx_train));
% F_test = gpuArray(F_binned(:,idx_test));

for i_th = 1:1:numel(threshold_for_event_vector)
    threshold= threshold_for_event_vector(i_th);
    key.threshold_for_event = threshold;
    
    F_thresholded=F_binned;
    if threshold>0
        F_thresholded(zscore(F_binned,[],2)<=threshold)=0;
    end
    
    if flag_zscore==0 %only centering the data
        F_thresholded = F_thresholded-mean(F_thresholded,2);
    else % zscoring the data
        F_thresholded=zscore(F_thresholded,[],2);
    end
    
    %     %trained
    %     F_thresholded_train=F_train;
    %     if threshold>0
    %         F_thresholded_train(zscore(F_train,[],2)<=threshold)=0;
    %     end
    %
    %     if flag_zscore==0 %only centering the data
    %         F_thresholded_train = F_thresholded_train-mean(F_thresholded_train,2);
    %     else % zscoring the data
    %         F_thresholded_train=zscore(F_thresholded_train,[],2);
    %     end
    
    %     %test
    %      F_thresholded_test=F_test;
    %     if threshold>0
    %         F_thresholded_test(zscore(F_test,[],2)<=threshold)=0;
    %     end
    %
    %     if flag_zscore==0 %only centering the data
    %         F_thresholded_test = F_thresholded_test-mean(F_thresholded_test,2);
    %     else % zscoring the data
    %         F_thresholded_test=zscore(F_thresholded_test,[],2);
    %     end
    
    
    %     [U,S,V]=svd(F_thresholded_train); % S time X neurons; % U time X time;  V neurons x neurons
    %     S= gather(S);
    %     singular_values =diag(S);
    %     V= gather(V);
    
    
    
    
    %                %% PCA example
    %                D=F_binned(1:10,1:1:1000);
    %                D=D';   % time (rows) by neurons (columns)
    %                D = D- mean(D); % centering
    %                [loadings,PCs,~, ~, explained] = pca(D);
    %                % PCs: time( rows) by PCs (columns; same as number of neurons)
    %                % Loadings: neurons( rows) by PCs (columns; same as number of neurons)
    %
    %                % Reconstructing the data from the PCs with dimensionality reduction
    %                %-----------------------------------------------------------
    %                FFF_reconstructed=PCs*loadings'; % reconstructing the original matrix from all PCs
    %                use_pcs=1:5; % take these PCs for dimensionality reduction
    %                FFF_reconstructed_partial=PCs(:,use_pcs)*loadings(:,use_pcs)'; % reconstructing the original matrix from some of the PCs
    %
    %                % Reconstructing the PCs from the data.
    %                % --------------------------------------------------
    %                % This is useful if we want to use a test set to reconstruct the PCs using loadings fromt he training set,
    %                % and measure how much  variance do the PCs identified in
    %                % the training set explains in the test set.
    %                % Training/Test set can also be spontaneous/behavior sessions
    %
    %                PCs_reconstructed = D*loadings;
    %                PCs_reconstructed_1stPC = D* loadings(:,1);
    %
    %                var_PCs_explained =var(PCs)/sum(var(PCs)); % should be the same as 'explained' - one of the outputs of the PCA function
    %
    %
    
    
    
    
    %% PCA cross validation by dividing the data in time into test/train set
    %----------------------------------------------------------------------
    D=gather(F_thresholded);
    D=D';   % time (rows) by neurons (columns)
    
    Dtrain = D(idx_train',:);
    Dtest = D(idx_test',:);
    
    Dtrain = Dtrain - mean(Dtrain);
    Dtest = Dtest - mean(Dtest);
    
    [loadings_train,PCs_train,~, ~, explained_train] = pca(Dtrain);
    [loadings_test,PCs_test,~, ~, explained_test] = pca(Dtest);
    
    % PCs: time( rows) by PCs (columns; same as number of neurons)
    % Loadings: neurons( rows) by PCs (columns; same as number of neurons)
    
    % Measuring shared variance
    % --------------------------------------------------
    % This is useful if we want to use a test set to reconstruct the PCs using loadings fromt he training set,
    % and measure how much  variance do the PCs identified in
    % the training set explains in the test set.
    % Training/Test set can also be spontaneous/behavior sessions
    
    PCs_reconstructed_test = Dtest* loadings_train;
    
    var_explained_train =var(PCs_train)/sum(var(PCs_train));
    var_explained_test =var(PCs_test)/sum(var(PCs_test));
    var_explained_test_reconst =var(PCs_reconstructed_test)/sum(var(PCs_reconstructed_test));
    %                    shared_variance1=var_explained_test./var_explained_train; % proportion of variance explained
    
    %                    shared_variance1=var_explained_test./var_explained_train; % proportion of variance explained
    %                    shared_variance2=var_explained_test-var_explained_train; % proportion of variance explained
    %                    shared_variance3=  1 - (var_explained_test-var_explained_train); % proportion of variance explained
    %                        my_shared_variance5= 1- (var_explained_test_reconst)./(var_explained_test_reconst+var_explained_train); % proportion of variance explained
    %                    my_shared_variance=  1 - (var_explained_test_reconst-var_explained_train)./(var_explained_test_reconst+var_explained_train); % proportion of variance explained
    
    shared_variance6=var_explained_test_reconst./var_explained_test; % proportion of variance explained
    
    shared_variance7=var(PCs_reconstructed_test)./var(PCs_train); % proportion of variance explained
    
    
    
    %% Shared variance explained based on Stringer et al. Science 2019
    
    D=F_binned (:,1:max([idx_test,idx_train]));
    ntrain=1:2:size(D,1);
    ntest=2:2:size(D,1);
    itest=idx_test;
    itrain=idx_train;
    
    npc = min([numel(ntrain),numel(ntest)]); %102
    
    [sneur, varneur, u, v] = SVCA(D, npc, ntrain, ntest, itrain, itest);
    %     sneur (shared variance of each covariance component)
    %     vneur (total variance of each covariance component)
    %     semilogx(sneur./varneur)
    
    
    SharedVarainceCalc_Ran(D(ntrain,itrain),D(ntest,itest))
    
    %% Populating
    key_insert=key;
    key_insert.shared_variance_stringer= gather(sneur);
    key_insert.total_variance_stringer= gather(varneur);
    
    key_insert.var_explained_train= var_explained_train;
    key_insert.var_explained_test= var_explained_test_reconst;
    key_insert.my_shared_variance= my_shared_variance;
    
    
    
    insert(self,key_insert);
    
end