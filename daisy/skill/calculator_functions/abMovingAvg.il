/* abMovingAvg.il

Group      Custom IC (UK), Cadence Design Systems Ltd.
Language   SKILL
Date       Jan 13, 2010 
Modified   Feb 07, 2013 

Performs a moving average. You specify the X window (typically
time) over which it (effectively) clips and averages, rolling
over the waveform.

; register the abMovingAvg() special function with the calculator
abRegMovingAvgSpecialFunction()

; example of usage:
abMovingAvg(v("signal" ?result 'tran) 5u)

The code is based on the VerilogA in solution 11277434. You may
want to adjust it if you don't like any DC offset it introduces
if the signal does not start at its average value...
The code produces the same result that the VerilogA model does.

To correct for the DC offset, one approach would be to change
this line:

      (setq result
            (iinteg (times k1 (difference waveform delayed))))

to:

      (setq result
            (plus
              (drGetElem (drGetWaveformYVec waveform) 0)
              (minus (average waveform))
              (iinteg (times k1 (difference waveform delayed)))))

This adds firstYval-average(waveform) to the result.

***************************************************

SCCS Info: @(#) abMovingAvg.il 02/07/13.13:25:12 1.3

*/

/*******************************************************************************
*  DISCLAIMER: The following code is provided for Cadence customers to use at  *
*   their own risk. The code may require modification to satisfy the           *
*   requirements of any user. The code and any modifications to the code may   *
*   not be compatible with current or future versions of Cadence products.     *
*   THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING WITHOUT     *
*   LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES OF MERCHANTABILITY *
*   OR FITNESS FOR A PARTICULAR USE.                                           *
*******************************************************************************/


/***************************************************************
*                                                              *
*                   (abCreateMovingAvgForm)                    *
*                                                              *
*            Create the form for the moving average            *
*                                                              *
***************************************************************/
(procedure (abCreateMovingAvgForm)
  (let (timeWindow gain)
       (setq timeWindow (ahiCreateStringField
                    ?name 'timeWindow
                    ?prompt "Time Window"
                    ?value ""
                    ))
       (setq gain (ahiCreateStringField
                    ?name 'gain
                    ?prompt "Gain"
                    ?value "1.0"
                    ))
       (calCreateSpecialFunctionsForm
        'abMovingAvgForm
        (list 
          (list timeWindow 0:0  180:20 90)
          (list gain 0:30  180:20 90)
          ))
       ))

/********************************************************************
*                                                                   *
*                  (abMovingAvgSpecialFunctionCB)                   *
*                                                                   *
* Callback for the moving average special function, which assembles *
*                the expression from the form values                *
*                                                                   *
********************************************************************/
(procedure (abMovingAvgSpecialFunctionCB)
  (calCreateSpecialFunction
   ?formSym 'abMovingAvgForm
   ?formInitProc 'abCreateMovingAvgForm
   ?formTitle "Moving Average"
   ?formCallback "calSpecialFunctionInput( 'abMovingAvg '(timeWindow gain))"
   ))

/***************************************************************
*                                                              *
*               (abRegMovingAvgSpecialFunction)                *
*                                                              *
*             Register the moving average function             *
*                                                              *
***************************************************************/
(procedure (abRegMovingAvgSpecialFunction)
  (calRegisterSpecialFunction
   (list "abMovingAvg" 'abMovingAvgSpecialFunctionCB))
  t
  )

/***************************************************************
*                                                              *
*    (abMovingAvg waveform timeWindow @optional (gain 1.0))    *
*                                                              *
* Given a waveform, a timewindow and an optional gain, compute *
*                     the moving average.                      *
*                                                              *
***************************************************************/
(procedure (abMovingAvg waveform timeWindow @optional (gain 1.0))
  (cond
   ;---------------------------------------------------------------------
   ; Handle ordinary waveform
   ;---------------------------------------------------------------------
   ((drIsWaveform waveform)
    (let (xVec len firstX lastX delayed k1 result sourceYVec yVec)
      ;------------------------------------------------------------------
      ; Find first and last x-values to clip the shifted waveform
      ;------------------------------------------------------------------
      (setq xVec (drGetWaveformXVec waveform))
      (setq firstX (drGetElem xVec 0))
      (setq len (drVectorLength xVec))
      (setq lastX (drGetElem xVec (sub1 len)))
      ;------------------------------------------------------------------
      ; Calculate the gain - taking into account the time window, 
      ; and then delay the signal
      ;------------------------------------------------------------------
      (setq k1 (quotient gain timeWindow))
      (setq delayed (clip (lshift waveform -timeWindow) firstX lastX))
      ;------------------------------------------------------------------
      ; Integrate the difference between the original waveform and teh
      ; delayed waveform (multiplied by the gain)
      ;------------------------------------------------------------------
      (setq result
            (iinteg (times k1 (difference waveform delayed))))
      ;------------------------------------------------------------------
      ; Copy units and axis name across from source waveform
      ;------------------------------------------------------------------
      (setq sourceYVec (drGetWaveformYVec waveform))
      (setq yVec (drGetWaveformYVec result))
      (putpropq yVec (getq sourceYVec units) units)
      (putpropq yVec (getq sourceYVec name) name)
      result
      )
    ) ; waveform
   ;---------------------------------------------------------------------
   ; Handle family
   ;---------------------------------------------------------------------
   ((famIsFamily waveform)
    (famMap 'abMovingAvg waveform timeWindow gain)
    ) ; family
   (t
    (error "abMovingAvg - can't handle %L\n" waveform)
    )
   ) ; cond
  )

