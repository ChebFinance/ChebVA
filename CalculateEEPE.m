function stcEEPE = CalculateEEPE(stcSimParams, stcMeasures)
% Description: Calcualtes the EEPE of a given EEE profile
%
% Input:    stcSimParams, structure that contains the time-vectors that
%                       will be needed
%           stcMeasures, structure that contains the EEE profile,
%                       both collat and uncollateralised
%
% Ouput: a structure with the Collateralised and Uncollateralised CVA
%
%           .UnCollat, EEPE of the uncollateralised profile
%           .Collat, EEPE of the collateralised profile
%
% Notes: 


%Uncollateralised:
tvec = stcSimParams.tvec;
tvec_EEE = tvec(tvec<=1);
size_UnCollat = length(tvec_EEE);
EEE_UnCollat = stcMeasures.UnCollat.EEE(1:size_UnCollat);
deltatvec_EEE = tvec_EEE(2:end) - tvec_EEE(1:end-1);
EEE_UnCollat_Av = ( EEE_UnCollat(2:end) + EEE_UnCollat(1:end-1) ) / 2;
stcEEPE.UnCollat = sum( deltatvec_EEE .* EEE_UnCollat_Av ) / tvec_EEE(end);

%Collateralised:
tvecVaR = stcSimParams.tvecVaR;
tvecVaR_EEE = tvecVaR(tvecVaR<=1);
sizeVaR = length(tvecVaR_EEE);
EEE_Collat = stcMeasures.Collat.EEE(1:sizeVaR);
deltatvecVaR_EEE = tvecVaR_EEE(2:end) - tvecVaR_EEE(1:end-1);
EEE_Collat_Av = ( EEE_Collat(2:end) + EEE_Collat(1:end-1) ) / 2;
stcEEPE.Collat = sum( deltatvecVaR_EEE .* EEE_Collat_Av ) / tvecVaR_EEE(end);


