% lf_gain_curve.m
% written by jared kofron <jared.kofron@gmail.com>
% displays a gain curve for the low frequency chain and reports the
% linear gain, linear dynamic range, and 1dB input compression point.
function [lg,ldr,cp] = lf_gain_curve()
% x points are power, spaced by 5dBm, from -136 to -51dBm in 18
% intervals.
px = linspace(-136,-51,18);
py = [-58 -54 -50 -45 -40 -35 -30 -25 -20 -15 -10 -5 -0 5 10 13 ...
      14.7 15.3];

% ok, now find the most linear region.  take all of the points and
% do a linear fit.  then drop the outermost two, then fit again,
% and repeat until the fit does not improve any more.
[p,S] = polyfit(px,py,1);
initial_res = S.normr;
test_res = 1000;
pxp = px;
pyp = py;
while 10*test_res > initial_res
    pxp = pxp(2:end-1);
    pyp = pyp(2:end-1);
    [p,S] = polyfit(pxp,pyp,1);
    test_res = S.normr;
end

% plot with title and such
ry = p(1)*px + ones(1,length(px))*p(2);
plot(px,py,px,ry);
title('Output power vs. input power');
xlabel('Pin (dBm)');
ylabel('Pout (dBm)');


% now subtract real from ideal to find 1dBCP
dif = py - ry;

% find points that are less than 0
cp_y = dif(dif < 0);
% that's the end of the stuff, so get those pts
cp_x = px(end-length(cp_y)+1:end);
% quadratic fit
[qp,qS] = polyfit(cp_x,cp_y,2);
% add one to both sides and solve.  the answer
% is the larger value.
r = roots([qp(1) qp(2) qp(3)+1]);


lg = p(2);
ldr = [pxp(1) pxp(end)];
cp = max(r);

% now add a line showing the compression point and make the legend.
line([cp cp],get(gca,'YLim'),'Color','red');
cp_str = sprintf('1dB input CP = %ddBm',round(cp));
legend('Measured gain curve','Ideal amp',cp_str,...
       'location','north');
end