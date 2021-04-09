function est_err = fn_compute_deviation_error (observed, predicted)

%% Normalization
% =========================================================================

% A) Both curves are normalized to percentage from observed peak
% --------------------------------------------------------------------------
% observed_normalized = 100* observed / nanmax (observed);
% predicted_normalized = 100* predicted / nanmax (observed);
% observed = observed_normalized;
% predicted = predicted_normalized; 

% B) Both curves are normalized to percentage from each own peak
% --------------------------------------------------------------------------
observed_normalized = 100* observed / nanmax (observed);
predicted_normalized = 100* predicted / nanmax (predicted);
observed = observed_normalized;
predicted = predicted_normalized; 



% 1) Root-mean-square
% =========================================================================

% A) WORKS WELL Root-mean-square deviation
% est_err = sqrt(nanmean((observed-predicted).^2)); 

% B) WORKS WELL    Normalized root-mean-square deviation 
% est_err = sqrt(nanmean((observed-predicted).^2))/(max(observed)-min(observed)); 

% % C) DOESN'T WORK WELL     The coefficient of variation of the RMSD, CV(RMSD), or more commonly CV(RMSE)
% est_err = sqrt(nanmean((observed-predicted).^2))/nanmean(predicted); 


% 2) Mean-square - all works well
% =========================================================================

% A)   Mean-square deviation
% est_err = nanmean((observed-predicted).^2); 

% B)   Normalized mean-square deviation 
est_err = nanmean((observed-predicted).^2)/(max(observed)-min(observed)); 

% % C)  The coefficient of variation of the  mean-square deviation,
% est_err = nanmean((observed-predicted).^2)/nanmean(predicted); 




% 3) Mean absolute error
% =========================================================================
% est_err = nanmean(abs(observed-predicted));



% figure;
% plot(observed,'-b');
% hold on;
% plot(predicted,'-r');
% title(num2str(est_err))