% y = b0*x + b1*x1 + b2*x2 - a1*y1 - a2*y2

clear; clc;
pkg load signal

% =============================
% USER PARAMETERS
% =============================
FC = 0.2;        % normalized cutoff
Q  = 0.707;      % quality factor
TYPE = "lp";     % lp | hp | bp

% =============================
% DESIGN
% =============================
w0 = pi * FC;
alpha = sin(w0)/(2*Q);

switch TYPE
  case "lp"
    b0 = (1 - cos(w0))/2;
    b1 = 1 - cos(w0);
    b2 = (1 - cos(w0))/2;
  case "hp"
    b0 = (1 + cos(w0))/2;
    b1 = -(1 + cos(w0));
    b2 = (1 + cos(w0))/2;
  case "bp"
    b0 =  sin(w0)/2;
    b1 =  0;
    b2 = -sin(w0)/2;
end

a0 = 1 + alpha;
a1 = -2*cos(w0);
a2 = 1 - alpha;

% Normalize
b = [b0 b1 b2] / a0;
a = [1 a1/a0 a2/a0];

% =============================
% FIXED POINT
% =============================
b_q = q15(b);
a_q = q15(a(2:3));

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
title("Biquad Response");
