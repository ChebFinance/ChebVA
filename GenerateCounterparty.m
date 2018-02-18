function stcCounterparty = GenerateCounterparty(strUnderlying,stcDefault)
% Description: Generates a structure with the counterparty information.
%
% Input: strUnderlying, string with the counterparty name.
%        stcDefault, structure with the default information
%           .default_type, string that indicates the functino PD=f(mSpot)
%           .paramX, parameters of the function PD = f(mSpot)
%
% Output: stcCounterparty, strucute with the inputs plus 
%            .mSpot
%            .mPDs
%         empty matrices that later will be filled with spot/PD informaion.
% 
% Notes:

stcCounterparty.strUnderlying = strUnderlying;
stcCounterparty.mSpot = [];
stcCounterparty.default_type = stcDefault.default_type;
stcCounterparty.param1 = stcDefault.param1;
stcCounterparty.param2 = stcDefault.param2;
stcCounterparty.param3 = stcDefault.param3;
stcCounterparty.param4 = stcDefault.param4;
stcCounterparty.mPDs = [];