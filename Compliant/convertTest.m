global numOfStatesP1P2;
for i = 1:numOfStatesP1P2
    [l1 l2 a1 a2 remain] = stnum2st(i);
    j = st2stnum(l1, l2, a1, a2, remain);
    if i ~= j
        disp([i j]);
    end
end