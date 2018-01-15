function [spectrogram, timevec, omegavec] = gabor(time, dipole_z, window_width)
% GABOR Calculate the Gabor transform.
%
%   Input:
%     time, dipole_z, window_width: the width of the Gabor window
%   Output:
%     [spectrogram, timevec, omegavec]
%     spectrogram is a 2d matrix whose columns are the spectrum at different
%     times.

  
  timevec_every = 100;

  g = @(t) exp(-t.^2 / window_width^2);

  
  dt = time(2) - time(1);
  M = 2^nextpow2(length(time));
  delta_omega = 2 * pi / (M * dt);
  omegavec = delta_omega * (0:M/2)'; % angular frequency vector
  timevec = time(1:timevec_every:length(time));
  
  
  dipoledot = lib.sptoeplitz([-2, 1, zeros(1, length(dipole_z)-2)], ...
                             [-2, 1, zeros(1, length(dipole_z)-2)]) ...
                                * dipole_z / (dt^2);
  dipoledot(end) = dipoledot(end-1);

  
  spectrogram = complex(zeros(length(omegavec), length(timevec)));
  for i = 1:length(timevec)
    window = g((time-timevec(i)));
    windowed_dipoledot_fft = fft(dipoledot .* window, M) * dt/(2*pi);

    % dipole is real
    spectrogram(:,i) = windowed_dipoledot_fft(1:M/2+1);
    spectrogram(2:end-1,i) = 2 * spectrogram(2:end-1,i);
  end

end
