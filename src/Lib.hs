{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies, BlockArguments #-}
{-# LANGUAGE NoMonomorphismRestriction, ScopedTypeVariables #-}

module Lib
  ( someFunc,
  )
where

import Control.Arrow hiding ((|||))
import Control.Monad (guard)
import Data.Function
import Diagrams.Align
import Diagrams.Prelude
import Graphics.Dynamic.Plot.R2

diag = circles ||| strutX 1 ||| (circles <> square 1)
  where
    d1 = juxtapose unitX (square 1) (circle 1 # fc red)
    d2 = juxtapose (unitX ^+^ unitY) (square 1) (circle 1 # fc green)
    d3 = juxtapose unitY (square 1) (circle 1 # fc blue)
    circles = mconcat [d1, d2, d3]

poly n = regPoly n 3 

{-
diag' :: Int -> PlainGraphicsR2
diag' n = hrule (2 * sum sizes) === circles # centerX
  where
    arrOpts =
      with
        & gaps .~ small
        & headLength .~ local 0.15

    sizes =
      [0.2, 0.5, 0.4, 0.7, 0.1, 0.3]
        & cycle
        & take n

    circles =
      sizes
        & zip [1 .. n]
        <&> ( \k@(sz, i) ->
                text (show k) # fontSizeL 0.2 # fc white <> circle sz # fc green # named i
            )
        <&> alignT
        & atPoints (regPoly n 10.0 & trailVertices)
        & applyAll [connectOutside' arrOpts j k | j <- [1 .. n -1], k <- [j + 1 .. n]]

-}

someFunc :: IO ()
someFunc = do
  let lplot str = legendName str . continFnPlot 
  plotWindow
    [
      -- shapePlot $ ([1, 5 .. 30]
      --              <&> ((atop & flip & uncurry)
      --                   . ((fc pink . poly)
      --                      &&& (fc white . fontSizeL 1 . text . show)))
      --                   & hcat
      --                   & centerX)
      --               === ([1 .. 30]
      --                    <&> ((atop & flip & uncurry)
      --                         . ((fc green . poly)
      --                            &&& (fc white . fontSizeL 1 . text . show)))
      --                     & hcat
      --                     & centerX)
      --               === ([1 .. 10]
      --                    <&> ((named &&& (fc red . poly) >>^ uncurry ($))
      --                          &&& (fc white . fontSizeL 1 . text . show)
      --                          >>^ (uncurry $ flip atop)
      --                          -- >>^ alignT
      --                        )
      --                     & atPoints (regPoly 10 20.0 & trailVertices)
      --                     & applyAll [connectOutside'
      --                                   (with
      --                                     & gaps .~ small
      --                                     & headLength .~ local 1)
      --                                   j
      --                                   k
      --                                  | (j :: Int) <- [1 .. 9], k <- [j+1 .. 10]
      --                                ]
      --                     & centerX),
      lplot "sin" sin,
      lplot "cos" cos,
      lplot "tan" tan,
      lplot "exp" exp,
      lplot "(^2)" (^2),
      lplot "(^3)" (^3),
      lplot "(^10)" (^10),
      lplot "(logBase 2)" (logBase 2),
      lplot "(logBase 3)" (logBase 3),
      lplot "(logBase 10)" (logBase 10) 
      -- colourPaintPlot \(x,y) -> case (x^2+y^2, atan2 y x) of
      --   (r, phi) -> do
      --     guard (sin (7*phi - 2*r) > r)
      --     return $ blend (tanh r) red green
      -- plot $ \(ViewXCenter xc) x -> sin xc + (x - xc) * cos xc
    ]
  return ()
