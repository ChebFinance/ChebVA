function [mCollatPrices, mCollatPDs] = calculate_CollatPricesAndPDs(mSumPrices,mPDs,stcSimParams)



CollatStepsJump = stcSimParams.CollatStepsJump;
mCollatPrices = mSumPrices(:,CollatStepsJump+1:end) - mSumPrices(:,1:end-CollatStepsJump);
mCollatPDs = mPDs(:,1:end-CollatStepsJump);

