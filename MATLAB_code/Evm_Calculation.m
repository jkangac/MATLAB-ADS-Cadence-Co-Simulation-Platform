function [rmsEVM,maxEVM,pctEVM,numSym] =  Evm_Calculation (TXSym, RXSym)
% This function is used to calculate the evm between tx signal and rx signal

evm = comm.EVM('MaximumEVMOutputPort',true,...
    'XPercentileEVMOutputPort',true, 'XPercentileValue',90,...
    'SymbolCountOutputPort',true);

[rmsEVM,maxEVM,pctEVM,numSym] = evm(TXSym,RXSym);
