
function error = calculateError(Vout_DFT, Vout_Eval)
    error = mean(abs(Vout_DFT - Vout_Eval));
%     error = max(abs(Vout_DFT) - abs(Vout_Eval));
end