function hlpStr = chelpinfo(txttype)

if strcmp(txttype,'info')
  hlpStr = ...
	['  =========================================                  '
	 '                                Cinterface                   '
	 '                      Converter PRES 1996                    '
	 '  =========================================                  '
	 '                                                             '
	 '  ConPres version 2.0                                        '
	 '                                                             '
	];
elseif strcmp(txttype,'help')
  hlpStr = ...                                                 
        ['  =========================================                  '
	 '                                Cinterface                   '
	 '                      Converter PRES 1996                    '
	 '  =========================================                  '
	 '                                                             '
	 '  Program to present results from measured AD converters.    '
	 '  (Observe! Information is from version 1.0)                 '
	 '  Menu operations:                                           '
	 '                                                             '
	 '  Loaded Data File,                                          '
	 '  file will be loaded with the csv format (se MatLab Help).  '
	 '                                                             '
 	 '  Start,                                                     '
	 '  defines start value of the data, could be used to zoom,    '
	 '  but also affects FFT, LogFFT, Histogram, DNL and INL.      '
	 '                                                             '
	 '  Stop,                                                      '
	 '  defines start value of the data, could be used to zoom,    '
	 '  but also affects FFT, LogFFT, Histogram, DNL and INL.      '
	 '                                                             '
	 '  Amax,                                                      '
	 '  defines the maximal positive amplitude.                    '
	 '                                                             '
	 '  Amin,                                                      '
	 '  defines the minimal negative amplitude.                    '
	 '                                                             '
	 '  No of bits,                                                '
	 '  the number of bits is displayed.                           '
	 '                                                             '
	 '  No of eff. bits,                                           '
	 '  will be computed as soon as the LogFFT mode once is chosen '
	 '                                                             '
	 '  Graph Type, here the PRES type can be chosen:              '
	 '     Time: Time domain PRES                                  '
	 '     FFT: Fast Fourier Transform, (Frequency Domain)         '
	 '     LogFFT: Logarithmic FFT, (Frequency Domain)             ' 
	 '     Histogram: Displays the occurance of digital codes      '
	 '     DNL: Differential Nonlinearity, DNL is computed stat-   '
	 '     istically, the ideal statistical beahaviour is set by   '
	 '     Function Type below.                                    '
	 '                                                             '
	 '  Function Type,                                             '
	 '  expected function type can be set; sine, sawtooth, ramp,   '
	 '  triangular, pulse 0/1 and pulse +/-                        '
	 '                                                             '
	 '  In the blue ACT special values is the displayed. Theese    '
	 '  values depend on the Graph Type and thE value chosen by    '
	 '  the graphic interface. The dashed line can be moved by     '
	 '  using the mouse. The position can also be given from the   '
	 '  keyboard.                                                  '
	 '                                                             '
	 '  The red ACT diaplays special computed values, as for       '
	 '  example SNR, SINAD, THD and similuar.                      '
	 '                                                             '
	 '  Info Button, displays this message.                        '
	 '                                                             '
	 '  Close Button, ends the program.                            '
	 '                                                             '
	 '  =================================================          '];
end;

