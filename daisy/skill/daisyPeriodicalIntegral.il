(procedure (daisyCreatePeriodicIntegralForm)
    (let (period)
       (setq period (ahiCreateStringField
                      ?name 'period
                      ?prompt "Period"
                      ?value ""
                      ))
         (calCreateSpecialFunctionsForm
          'daisyPeriodicIntegralForm
          (list 
            (list period 0:0  180:20 90)
            ))
         ))

(procedure (daisyPeriodicIntegralSpecialFunctionCB)
    (calCreateSpecialFunction
        ?formSym 'daisyPeriodicIntegralForm
        ?formInitProc 'daisyCreatePeriodicIntegralForm
        ?formTitle "Periodic Integral"
        ?formCallback "calSpecialFunctionInput( 'daisyPeriodicIntegral '(period))"
    )
)

(procedure (daisyRegPeriodicIntegralSpecialFunction)
    (calRegisterSpecialFunction
        (list "daisyPeriodicIntergal" 'daisyPeriodicIntegralSpecialFunctionCB))
    t
    )
        
(procedure (daisyPeriodicIntegral waveform period)
    (cond
        ((drIsWaveform waveform)
            (let (xWF yWF len firstX lastX delayed xRes yRes)
                (setq xWF (drGetWaveformXVec waveform))
                (setq yWF (drGetWaveformYVec waveform))
                (setq len (drVectorLength xWF))
                (setq firstX (drGetElem xWF 0))
                (setq lastX (drGetElem xWF (sub1 len)))
                (setq xRes (drCreateVec (drType xWF) 1))
                (setq yRes (drCreateVec (drType yWF) 1))
                ; Loop over period, integrate and add to result
                (for i 1 (floor (lastX - firstX)/period)
                        (drAddElem xRes i*period)
                        (drAddElem yRes integ(clip(waveform (i-1)*period i*period)))
                )
                
                (setq result (drCreateEmptyWaveform))
                (drPutWaveformXVec result xRes)
                (drPutWaveformYVec result yRes)
                (putpropq yRes (getq yWF units) units)
                (putpropq yRes (getq yWF name) name)
                (putpropq xRes (getq xWF units) units)
                (putpropq xRes (getq xWF name) name)
                result
            )
        ) ; waveform
        ((famIsFamily waveform)
            (famMap 'daisyPeriodicIntegral waveform period)
            )
        (t
            (error "daisyPeriodicalIntegral - can't handle %L\n" waveform)
        )
    ) ; cond
)
