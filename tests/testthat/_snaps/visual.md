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
       cerebellum cortex      10618   21228 -52.9   1.0 -92.8 -33.1 -63.8  -2.3
                thalamus       1864    3724 -26.4  -0.4 -36.8  -2.2  -6.7  16.8
                 caudate       1512    3028 -21.3  -6.4 -23.0  24.4  -8.9  23.4
                 putamen       1998    3992 -36.4 -12.1 -21.8  17.7 -15.2  12.6
                pallidum        723    1442 -27.9 -12.0 -17.9   5.8  -8.8   4.7
              brain stem       4608    9212 -16.5  17.7 -49.6 -14.4 -70.5  -0.8
             hippocampus       1892    3780 -37.3 -12.4 -42.9  -7.2 -31.1   4.1
                amygdala        710    1416 -32.7 -14.3 -14.6  -1.1 -31.0 -10.9
          accumbens area        432     860 -14.9  -5.0   2.3  17.8 -15.0  -3.2
               ventraldc       1683    3366 -29.0   1.3 -30.8   0.5 -21.3  -2.5
                  vessel         77     150 -30.5 -24.9  -5.4  -0.5 -11.8  -9.2
          choroid plexus        877    1770 -35.5   0.5 -39.7  20.3 -13.6  18.7
       cerebellum cortex      10823   21650  -0.5  54.1 -92.9 -33.1 -64.0  -2.2
                thalamus       1853    3702   1.0  25.7 -36.6  -1.2  -5.6  17.2
                 caudate       1620    3244   6.5  22.2 -22.6  23.8  -7.7  24.7
                 putamen       1935    3866  12.8  36.4 -20.7  18.0 -15.1  12.7
                pallidum        688    1372  13.8  28.9 -17.4   5.5  -8.0   5.1
             hippocampus       1877    3750  14.3  38.9 -42.7  -7.5 -30.9   4.9
                amygdala        730    1456  15.5  33.9 -13.9  -0.5 -31.4 -10.8
          accumbens area        420     836   5.6  15.5   1.3  18.8 -14.2  -4.2
               ventraldc       1683    3366   1.6  30.9 -30.6   0.8 -20.8  -1.2
                  vessel         71     138  28.3  32.4  -4.8   0.4 -11.7  -9.6
          choroid plexus       1194    2352  -0.2  38.0 -39.4  19.9 -14.2  21.0
            optic chiasm        170     348  -6.2   6.2  -2.4   2.5 -21.6 -15.9
            cc posterior        518    1032  -2.5   2.8 -44.7 -26.3   6.8  26.0
        cc mid posterior        314     620  -2.4   2.4 -26.8 -10.8  18.6  29.2
              cc central        267     530  -2.4   2.4 -10.6   4.9  21.4  29.6
         cc mid anterior        305     606  -2.4   2.4   4.4  19.8  13.1  26.2
             cc anterior        504    1004  -2.5   3.0  15.3  32.9  -3.3  17.0
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
       cerebellum cortex      10618   21228 -52.9   1.0  -92.8 -33.1 -63.8  -2.3
                thalamus       1864    3724 -26.4  -0.4  -36.8  -2.2  -6.7  16.8
                 caudate       1512    3028 -21.3  -6.4  -23.0  24.4  -8.9  23.4
                 putamen       1998    3992 -36.4 -12.1  -21.8  17.7 -15.2  12.6
                pallidum        723    1442 -27.9 -12.0  -17.9   5.8  -8.8   4.7
              brain stem       4608    9212 -16.5  17.7  -49.6 -14.4 -70.5  -0.8
             hippocampus       1892    3780 -37.3 -12.4  -42.9  -7.2 -31.1   4.1
                amygdala        710    1416 -32.7 -14.3  -14.6  -1.1 -31.0 -10.9
          accumbens area        432     860 -14.9  -5.0    2.3  17.8 -15.0  -3.2
               ventraldc       1683    3366 -29.0   1.3  -30.8   0.5 -21.3  -2.5
                  vessel         77     150 -30.5 -24.9   -5.4  -0.5 -11.8  -9.2
          choroid plexus        877    1770 -35.5   0.5  -39.7  20.3 -13.6  18.7
       cerebellum cortex      10823   21650  -0.5  54.1  -92.9 -33.1 -64.0  -2.2
                thalamus       1853    3702   1.0  25.7  -36.6  -1.2  -5.6  17.2
                 caudate       1620    3244   6.5  22.2  -22.6  23.8  -7.7  24.7
                 putamen       1935    3866  12.8  36.4  -20.7  18.0 -15.1  12.7
                pallidum        688    1372  13.8  28.9  -17.4   5.5  -8.0   5.1
             hippocampus       1877    3750  14.3  38.9  -42.7  -7.5 -30.9   4.9
                amygdala        730    1456  15.5  33.9  -13.9  -0.5 -31.4 -10.8
          accumbens area        420     836   5.6  15.5    1.3  18.8 -14.2  -4.2
               ventraldc       1683    3366   1.6  30.9  -30.6   0.8 -20.8  -1.2
                  vessel         71     138  28.3  32.4   -4.8   0.4 -11.7  -9.6
          choroid plexus       1194    2352  -0.2  38.0  -39.4  19.9 -14.2  21.0
            optic chiasm        170     348  -6.2   6.2   -2.4   2.5 -21.6 -15.9
            cc posterior        518    1032  -2.5   2.8  -44.7 -26.3   6.8  26.0
        cc mid posterior        314     620  -2.4   2.4  -26.8 -10.8  18.6  29.2
              cc central        267     530  -2.4   2.4  -10.6   4.9  21.4  29.6
         cc mid anterior        305     606  -2.4   2.4    4.4  19.8  13.1  26.2
             cc anterior        504    1004  -2.5   3.0   15.3  32.9  -3.3  17.0
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

