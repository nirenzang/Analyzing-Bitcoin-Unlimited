function [ l1, l2, a1, a2, remain] = stnum2st( stnum )
%STNUM2STP1 maps a statenum in Phase 1 to a state
% remain = 0 means we are at phase 1, any other number means we are at
%     phase 2
global mid2Until AD;
% stnum = remain*(mid2Until(AD)+1) + mid3 + 1;
stnum = stnum-1;
mid3 = mod(stnum, mid2Until(AD)+1);
remain = floor(stnum/(mid2Until(AD)+1));
if mid3 == 0 % base state
    l1 = 0; l2 = 0; a1 = 0; a2 = 0;
else % not base state, l2 is at least 1
    % [1, mid2Until(1)] means l2 = 1
    % else mid3 within [mid2Until(l2-1)+1, mid2Until(l2)]
    for i = 1:12
        if mid3 <= mid2Until(i)
            l2 = i;
            break
        end
    end
    if l2 ~= 1
        mid2 = mid3-(mid2Until(l2-1)+1);
    else
        mid2 = mid3-1;
    end
    % mid2 = mid1*l2+(a2-1);
    a2 = mod(mid2, l2)+1;
    mid1 = floor(mid2/l2);
    % mid1 = l1*(l1+1)/2+a1;
    l1 = floor((-1+sqrt(1+8*mid1))/2);
    a1 = mid1 - l1*(l1+1)/2;
    if a1 > l1 || a1 < 0
        disp(['parse mid1 wrong: ' num2str(mid1)]);
    end
    % l1 range from 0 to l2
    % a1 range from 0 to l1
    % l2 range from 1 to AD
    % a2 range from 1 to l2
end