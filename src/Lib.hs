module Lib
  ( someFunc,
  )
where

import Data.Function
import Diagrams.Align
import Diagrams.Prelude
import Graphics.Dynamic.Plot.R2

diag = circles ||| strutX 1 ||| (circles <> square 1)
  where
    d1 = juxtapose unitX (square 1) (circle 1 & fc red)
    d2 = juxtapose (unitX ^+^ unitY) (square 1) (circle 1 & fc green)
    d3 = juxtapose unitY (square 1) (circle 1 & fc blue)
    circles = mconcat [d1, d2, d3]

diag' n = hrule (2 * sum sizes) === circles & centerX
  where
    arrOpts =
      with
        & gaps .~ small
        & headLength .~ local 0.15

    sizes = [0.2, 0.5, 0.4, 0.7, 0.1, 0.3] & cycle & take n

    circles =
      sizes
        & zip [1 .. n]
        <&> ( \k@(sz, i) ->
                text (show k & fontSizeL 0.2 & fc white)
                  <> circle sz & fc green & named i
            )
        <&> alignT
        & atPoints (regPoly n 10 & trailVertices)
        & applyAll [connectOutside' arrOpts j k | j <- [1 .. n -1], k <- [j + 1 .. n]]

someFunc :: IO ()
someFunc = do
  plotWindow
    [ shapePlot diag,
      fnPlot sin,
      plot $ \(ViewXCenter xc) x -> sin xc + (x - xc) * cos xc,
      shapePlot $ diag' 10
    ]
  return ()
