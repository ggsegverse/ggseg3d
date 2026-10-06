# dk cortical atlas produces stable mesh layout

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
                 name n_vertices n_faces x_min x_max  y_min y_max z_min z_max
        left inflated      10242   20480   -83   0.0 -108.0 108.0 -72.9  73.0
       right inflated      10242   20480     0  81.8 -107.7 107.7 -73.3  73.3
        color_mode n_colors opacity is_flatmap
       vertexcolor       36       1      FALSE
       vertexcolor       36       1      FALSE

# dk single hemisphere has medial edge at midline

    Code
      print(widget_summary(lh), row.names = FALSE)
    Output
                name n_vertices n_faces x_min x_max y_min y_max z_min z_max
       left inflated      10242   20480   -83     0  -108   108 -72.9    73
        color_mode n_colors opacity is_flatmap
       vertexcolor       36       1      FALSE

---

    Code
      print(widget_summary(rh), row.names = FALSE)
    Output
                 name n_vertices n_faces x_min x_max  y_min y_max z_min z_max
       right inflated      10242   20480     0  81.8 -107.7 107.7 -73.3  73.3
        color_mode n_colors opacity is_flatmap
       vertexcolor       36       1      FALSE

# dk pial surface produces stable mesh layout

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
             name n_vertices n_faces x_min x_max  y_min y_max z_min z_max  color_mode
        left pial      10242   20480   -70     0 -104.7  68.9 -48.3  78.1 vertexcolor
       right pial      10242   20480     0    70 -104.4  69.2 -48.4  79.2 vertexcolor
       n_colors opacity is_flatmap
             36       1      FALSE
             36       1      FALSE

# aseg subcortical atlas produces stable mesh layout

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
                    name n_vertices n_faces x_min x_max y_min y_max z_min z_max
       cerebellum cortex      10618   21228 -53.2   0.7 -68.1  -8.5 -75.4 -13.9
                thalamus       1864    3724 -26.7  -0.7 -12.1  22.5 -18.3   5.2
                 caudate       1512    3028 -21.6  -6.8   1.7  49.1 -20.5  11.8
                 putamen       1998    3992 -36.7 -12.4   2.8  42.4 -26.8   1.0
                pallidum        723    1442 -28.2 -12.3   6.8  30.5 -20.4  -6.9
              brain stem       4608    9212 -16.8  17.4 -25.0  10.3 -82.1 -12.4
             hippocampus       1892    3780 -37.7 -12.7 -18.2  17.5 -42.7  -7.5
                amygdala        710    1416 -33.0 -14.6  10.0  23.5 -42.6 -22.5
          accumbens area        432     860 -15.2  -5.3  27.0  42.4 -26.6 -14.8
               ventraldc       1683    3366 -29.3   1.0  -6.2  25.1 -32.9 -14.1
                  vessel         77     150 -30.8 -25.2  19.3  24.2 -23.4 -20.8
          choroid plexus        877    1770 -35.9   0.2 -15.0  45.0 -25.2   7.1
       cerebellum cortex      10823   21650  -0.8  53.8 -68.3  -8.4 -75.6 -13.8
                thalamus       1853    3702   0.7  25.4 -11.9  23.5 -17.1   5.6
                 caudate       1620    3244   6.2  21.8   2.1  48.4 -19.3  13.1
                 putamen       1935    3866  12.5  36.0   3.9  42.6 -26.7   1.1
                pallidum        688    1372  13.4  28.5   7.3  30.2 -19.6  -6.5
             hippocampus       1877    3750  14.0  38.6 -18.1  17.1 -42.5  -6.7
                amygdala        730    1456  15.1  33.6  10.8  24.1 -43.0 -22.4
          accumbens area        420     836   5.3  15.2  26.0  43.5 -25.8 -15.8
               ventraldc       1683    3366   1.2  30.6  -5.9  25.5 -32.4 -12.8
                  vessel         71     138  28.0  32.0  19.8  25.1 -23.4 -21.2
          choroid plexus       1194    2352  -0.5  37.7 -14.7  44.6 -25.8   9.4
            optic chiasm        170     348  -6.5   5.9  22.3  27.1 -33.2 -27.5
            cc posterior        518    1032  -2.8   2.4 -20.1  -1.6  -4.8  14.4
        cc mid posterior        314     620  -2.7   2.1  -2.1  13.9   7.1  17.6
              cc central        267     530  -2.7   2.1  14.0  29.5   9.7  18.0
         cc mid anterior        305     606  -2.7   2.1  29.1  44.5   1.4  14.6
             cc anterior        504    1004  -2.8   2.6  40.0  57.6 -15.0   5.4
       color_mode n_colors opacity is_flatmap
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE
        facecolor        1       1      FALSE

# cerebellar atlas produces stable mesh layout

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
             name n_vertices n_faces x_min x_max y_min y_max z_min z_max  color_mode
       cerebellum      30013   57665 -53.6    56 -91.7     0 -64.6     0 vertexcolor
       n_colors opacity is_flatmap
              3       1      FALSE

# cortical + glassbrain composes as expected

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
                    name n_vertices n_faces x_min x_max  y_min y_max z_min z_max
        glass brain left      10242   20480   -83   0.0 -108.0 108.0 -72.9  73.0
       glass brain right      10242   20480     0  81.8 -107.7 107.7 -73.3  73.3
           left inflated      10242   20480   -83   0.0 -108.0 108.0 -72.9  73.0
          right inflated      10242   20480     0  81.8 -107.7 107.7 -73.3  73.3
        color_mode n_colors opacity is_flatmap
       vertexcolor        1     0.2      FALSE
       vertexcolor        1     0.2      FALSE
       vertexcolor       36     1.0      FALSE
       vertexcolor       36     1.0      FALSE

# aseg + glassbrain composes as expected

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
                    name n_vertices n_faces x_min x_max  y_min y_max z_min z_max
        glass brain left      10242   20480 -83.0   0.0 -108.0 108.0 -72.9  73.0
       glass brain right      10242   20480   0.0  81.8 -107.7 107.7 -73.3  73.3
       cerebellum cortex      10618   21228 -53.2   0.7  -68.1  -8.5 -75.4 -13.9
                thalamus       1864    3724 -26.7  -0.7  -12.1  22.5 -18.3   5.2
                 caudate       1512    3028 -21.6  -6.8    1.7  49.1 -20.5  11.8
                 putamen       1998    3992 -36.7 -12.4    2.8  42.4 -26.8   1.0
                pallidum        723    1442 -28.2 -12.3    6.8  30.5 -20.4  -6.9
              brain stem       4608    9212 -16.8  17.4  -25.0  10.3 -82.1 -12.4
             hippocampus       1892    3780 -37.7 -12.7  -18.2  17.5 -42.7  -7.5
                amygdala        710    1416 -33.0 -14.6   10.0  23.5 -42.6 -22.5
          accumbens area        432     860 -15.2  -5.3   27.0  42.4 -26.6 -14.8
               ventraldc       1683    3366 -29.3   1.0   -6.2  25.1 -32.9 -14.1
                  vessel         77     150 -30.8 -25.2   19.3  24.2 -23.4 -20.8
          choroid plexus        877    1770 -35.9   0.2  -15.0  45.0 -25.2   7.1
       cerebellum cortex      10823   21650  -0.8  53.8  -68.3  -8.4 -75.6 -13.8
                thalamus       1853    3702   0.7  25.4  -11.9  23.5 -17.1   5.6
                 caudate       1620    3244   6.2  21.8    2.1  48.4 -19.3  13.1
                 putamen       1935    3866  12.5  36.0    3.9  42.6 -26.7   1.1
                pallidum        688    1372  13.4  28.5    7.3  30.2 -19.6  -6.5
             hippocampus       1877    3750  14.0  38.6  -18.1  17.1 -42.5  -6.7
                amygdala        730    1456  15.1  33.6   10.8  24.1 -43.0 -22.4
          accumbens area        420     836   5.3  15.2   26.0  43.5 -25.8 -15.8
               ventraldc       1683    3366   1.2  30.6   -5.9  25.5 -32.4 -12.8
                  vessel         71     138  28.0  32.0   19.8  25.1 -23.4 -21.2
          choroid plexus       1194    2352  -0.5  37.7  -14.7  44.6 -25.8   9.4
            optic chiasm        170     348  -6.5   5.9   22.3  27.1 -33.2 -27.5
            cc posterior        518    1032  -2.8   2.4  -20.1  -1.6  -4.8  14.4
        cc mid posterior        314     620  -2.7   2.1   -2.1  13.9   7.1  17.6
              cc central        267     530  -2.7   2.1   14.0  29.5   9.7  18.0
         cc mid anterior        305     606  -2.7   2.1   29.1  44.5   1.4  14.6
             cc anterior        504    1004  -2.8   2.6   40.0  57.6 -15.0   5.4
        color_mode n_colors opacity is_flatmap
       vertexcolor        1    0.15      FALSE
       vertexcolor        1    0.15      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE
         facecolor        1    1.00      FALSE

# cerebellar + glassbrain composes as expected

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
                    name n_vertices n_faces x_min x_max  y_min y_max z_min z_max
        glass brain left      10242   20480 -83.0   0.0 -108.0 108.0 -72.9  73.0
       glass brain right      10242   20480   0.0  81.8 -107.7 107.7 -73.3  73.3
              cerebellum      30013   57665 -53.6  56.0  -91.7   0.0 -64.6   0.0
        color_mode n_colors opacity is_flatmap
       vertexcolor        1    0.15      FALSE
       vertexcolor        1    0.15      FALSE
       vertexcolor        3    1.00      FALSE

