function dipoledot_fft = hhgspec(spectrogram, timevec, window_width, tmin, tmax)
%HHGSPEC Calculate the high harmonic generation spectrum.
%
%   Input:
%     spectrogram, timevec, window_width, tmin, tmax
%   Output:
%     hhg spectrum as a function of frequencies


  T = tmax - tmin;

  dt = timevec(2) - timevec(1);

  imin = find(timevec <= tmin, 1, 'last');
  imax = find(timevec >= tmax, 1);

  dipoledot_fft = sum(spectrogram(:, imin:imax), 2) * dt / ...
      (sqrt(pi) * window_width * erf(T / (2*window_width)));

end

