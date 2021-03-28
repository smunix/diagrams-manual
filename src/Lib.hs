module Lib
  ( someFunc,
  )
where

import Diagrams.Prelude
import Graphics.Dynamic.Plot.R2

exJuxtaposition = circles ||| strutX 1 ||| (circles <> square 1)
  where
    d1 = juxtapose unitX (square 1) (circle 1 # fc red)
    d2 = juxtapose (unitX ^+^ unitY) (square 1) (circle 1 # fc green)
    d3 = juxtapose unitY (square 1) (circle 1 # fc blue)
    circles = mconcat [d1, d2, d3]

someFunc :: IO ()
someFunc = do
  plotWindow
    [ shapePlot,
      fnPlot sin,
      plot $ \(ViewXCenter xc) x -> sin xc + (x - xc) * cos xc
    ]
  -- mainWith $ myCircle === exJuxtaposition
  return ()
