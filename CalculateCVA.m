function stcCVA = CalculateCVA(stcSimParams, stcMeasures, s_cpty, s_mine)
% Description: Calcualtes the CVA
%
% Input:    stcSimParams, structure that contains the time-vectors that
%                       will be needed
%           stcMeasures, structure that contains the EPE and ENE profiles,
%                       both collat and uncollateralised
%           s_cpty, credit spread of the counterparty (in natural units,
%                       e.g., 0.0500)
%           s_mine, credit spread of my bank (in natural units,
%                       e.g., 0.0500)
%
% Ouput: a structure wioth the Collateralised and Uncollateralised CVA
%
%           .UnCollat, CVA of the uncollateralised profile
%           .Collat, CVA of the collateralised profile
%
% Notes: it proxies CVA by  ( integral(EPE)*s_cpty + integral(ENE)*s_mine )


%Uncollateralised:
deltatvec_UnCollat =  stcSimParams.tvec(2:end) - stcSimParams.tvec(1:end-1);
EPE_UnCollat_Av = ( stcMeasures.UnCollat.EPE(2:end) + stcMeasures.UnCollat.EPE(1:end-1) ) / 2;
ENE_UnCollat_Av = ( stcMeasures.UnCollat.ENE(2:end) + stcMeasures.UnCollat.ENE(1:end-1) ) / 2;
CVA_UnCollat_asset = sum( deltatvec_UnCollat .* EPE_UnCollat_Av ) * s_cpty;
CVA_UnCollat_liab = sum( deltatvec_UnCollat .* ENE_UnCollat_Av ) * s_mine;
stcCVA.UnCollat = CVA_UnCollat_asset + CVA_UnCollat_liab;


%Collateralised
deltatvec_Collat =  stcSimParams.tvecVaR(2:end) - stcSimParams.tvecVaR(1:end-1);
EPE_Collat_Av = ( stcMeasures.Collat.EPE(2:end) + stcMeasures.Collat.EPE(1:end-1) ) / 2;
ENE_Collat_Av = ( stcMeasures.Collat.ENE(2:end) + stcMeasures.Collat.ENE(1:end-1) ) / 2;
CVA_Collat_asset = sum ( deltatvec_Collat .* EPE_Collat_Av ) * s_cpty;
CVA_Collat_liab = sum ( deltatvec_Collat .* ENE_Collat_Av ) * s_mine;
stcCVA.Collat = CVA_Collat_asset + CVA_Collat_liab;