% FIR (Transposed Form - FPGA friendly)
% y[n] = h[0]·x[n] + h[1]·x[n-1] + ... + h[N-1]·x[n-(N-1)]

clear; clc;
pkg load signal

% =============================
% USER PARAMETERS
% =============================
NTAPS   = 129;       % number of taps
FC      = 0.25;      % normalized cutoff (0..1, 1 = Nyquist)
WINDOW  = "hamming"; % hamming | hann | rectangular
QFORMAT = "Q1.15";

% =============================
% FIR DESIGN (FLOAT)
% =============================
b = fir1(NTAPS-1, FC);

switch WINDOW
  case "hann"
    b = b .* hann(NTAPS)';
  case "hamming"
    b = b .* hamming(NTAPS)';
end

% =============================
% FIXED POINT
% =============================
b_q = q15(b);

% =============================
% EXPORT
% =============================
write_mem("fir_coef.mem", b_q);
save("-ascii", "fir_coef.txt", "b_q");

% =============================
% PLOT (SANITY CHECK)
% =============================
freqz(b, 1, 1024);
title("FIR Frequency Response");
