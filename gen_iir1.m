% y[n] = b0*x[n] + b1*x[n-1] - a1*y[n-1]

clear; clc;
pkg load signal

% =============================
% USER PARAMETERS
% =============================
FC = 0.1;        % normalized cutoff (0..1)
TYPE = "lp";     % lp | hp

% =============================
% DESIGN (FLOAT)
% =============================
if TYPE == "lp"
  alpha = exp(-2*pi*FC);
  b0 = 1 - alpha;
  b1 = 0;
  a1 = -alpha;
else
  alpha = exp(-2*pi*FC);
  b0 = (1 + alpha)/2;
  b1 = -(1 + alpha)/2;
  a1 = -alpha;
end

b = [b0 b1];
a = [1 a1];

% =============================
% FIXED POINT
% =============================
b_q = q15(b);
a_q = q15(a(2));   % only a1 stored

% =============================
% EXPORT (SINGLE MEM FILE)
% =============================
coef_q = [b_q a_q];   % [b0 b1 a1]

write_mem("iir1_coef.mem", coef_q);
save("-ascii", "iir1_coef.txt", "coef_q");

% =============================
% PLOT
% =============================
freqz(b, a, 1024);
title("IIR 1st Order Response");
