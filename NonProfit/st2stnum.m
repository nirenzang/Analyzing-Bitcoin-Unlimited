function stnum = st2stnum(l1, l2, a1, a2, remain)
global mid2Until AD;
%ST2STNUM map a state in Phase 1 to a statenum
if remain < 0
    remain = 0;
end
if l2 == 0 % base state
    mid3 = 0;
else % not base state, l2 is at least 1
    % l1 range from 0 to l2
    % a1 range from 0 to l1
    % l2 range from 1 to AD
    % a2 range from 1 to l2
    % mid1 encode l1 and a1, range from 0 to (l2^2+3*l2)/2
    mid1 = l1*(l1+1)/2+a1;
    % mid2 encode mid1 and a2-1, given l2
    %     range from 0 to (l2^2+3*l2)/2*l2+l2-1
    mid2 = mid1*l2+(a2-1);
    % mid3 encode mid2 and l2 (including l2=0), 0 means l2=0,
    %     [1, mid2Until(1)] means l2 = 1,
    %     [mid2Until(i-1)+1 mid2Until(i)] means l2 = i
    if l2 == 1
        mid3 = mid2+1;
    else
        mid3 = mid2+mid2Until(l2-1)+1;
    end
end
stnum = remain*(mid2Until(AD)+1) + mid3 + 1;