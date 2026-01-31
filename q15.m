function y = q15(x)
  y = round(x * 2^15);
  y(y >  32767) =  32767;
  y(y < -32768) = -32768;
end
