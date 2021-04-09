function SSE=My_Von_Mises_Fit_no_baseline(params,Input,Actual_Output)
% see also circ_vmpdf; - for probability density function

peak_FR=params(1);
mu=params(2);
k=params(3);

Fitted_Curve=abs(peak_FR)*exp((k).*cos(Input-mu) -1);
% Fitted_Curve=abs(peak_FR)*exp(abs(k).*cos(Input-mu) -1);

% Fitted_Curve=abs(peak_FR)*(exp(k.*cos(Input-mu))./(2*pi*besseli(0,k)))+abs(baseline);

Error_Vector=Fitted_Curve - Actual_Output;
SSE=sum(Error_Vector.^2);