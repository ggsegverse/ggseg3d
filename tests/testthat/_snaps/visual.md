# dk cortical atlas produces stable mesh layout

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
                 name n_vertices n_faces x_min x_max  y_min y_max z_min z_max
        left inflated      10242   20480   -83   0.0 -108.0 108.0 -72.9  73.0
       right inflated      10242   20480     0  81.8 -107.7 107.7 -73.3  73.3
        color_mode n_colors color_digest opacity is_flatmap
       vertexcolor       36     e4a6ca19       1      FALSE
       vertexcolor       36     e4a6ca19       1      FALSE

# dk single hemisphere has medial edge at midline

    Code
      print(widget_summary(lh), row.names = FALSE)
    Output
                name n_vertices n_faces x_min x_max y_min y_max z_min z_max
       left inflated      10242   20480   -83     0  -108   108 -72.9    73
        color_mode n_colors color_digest opacity is_flatmap
       vertexcolor       36     e4a6ca19       1      FALSE

---

    Code
      print(widget_summary(rh), row.names = FALSE)
    Output
                 name n_vertices n_faces x_min x_max  y_min y_max z_min z_max
       right inflated      10242   20480     0  81.8 -107.7 107.7 -73.3  73.3
        color_mode n_colors color_digest opacity is_flatmap
       vertexcolor       36     e4a6ca19       1      FALSE

# dk pial surface produces stable mesh layout

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
             name n_vertices n_faces x_min x_max  y_min y_max z_min z_max  color_mode
        left pial      10242   20480   -70     0 -104.7  68.9 -48.3  78.1 vertexcolor
       right pial      10242   20480     0    70 -104.4  69.2 -48.4  79.2 vertexcolor
       n_colors color_digest opacity is_flatmap
             36     e4a6ca19       1      FALSE
             36     e4a6ca19       1      FALSE

# aseg subcortical atlas produces stable mesh layout

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
                   name n_vertices n_faces x_min x_max y_min y_max z_min z_max
             Cerebellum      21232   42456 -53.2   0.7 -68.1  -8.5 -75.4 -13.9
             Cerebellum      21232   42456 -53.2   0.7 -68.1  -8.5 -75.4 -13.9
               Thalamus       3726    7448 -26.7  -0.6 -12.1  22.5 -18.3   5.2
               Thalamus       3726    7448 -26.7  -0.6 -12.1  22.5 -18.3   5.2
        Thalamus Proper       3726    7448 -26.7  -0.6 -12.1  22.5 -18.3   5.2
        Thalamus Proper       3726    7448 -26.7  -0.6 -12.1  22.5 -18.3   5.2
                Caudate       3026    6056 -21.7  -6.7   1.7  49.1 -20.5  11.8
                Caudate       3026    6056 -21.7  -6.7   1.7  49.1 -20.5  11.8
                Putamen       3994    7984 -36.7 -12.4   2.8  42.4 -26.8   1.1
                Putamen       3994    7984 -36.7 -12.4   2.8  42.4 -26.8   1.1
               Pallidum       1444    2884 -28.2 -12.3   6.8  30.5 -20.4  -6.9
               Pallidum       1444    2884 -28.2 -12.3   6.8  30.5 -20.4  -6.9
             Brain Stem       9214   18424 -16.9  17.4 -25.0  10.4 -82.2 -12.4
            Hippocampus       3782    7560 -37.7 -12.7 -18.2  17.5 -42.7  -7.5
            Hippocampus       3782    7560 -37.7 -12.7 -18.2  17.5 -42.7  -7.5
               Amygdala       1418    2832 -33.0 -14.6  10.0  23.5 -42.6 -22.5
               Amygdala       1418    2832 -33.0 -14.6  10.0  23.5 -42.6 -22.5
         accumbens area        862    1720 -15.2  -5.3  27.0  42.4 -26.6 -14.8
              ventraldc       3366    6732 -29.6   1.0  -6.2  25.2 -33.1 -14.1
                 vessel        152     300 -30.8 -25.2  19.3  24.3 -23.4 -20.8
         choroid plexus       1762    3540 -35.9   0.2 -15.1  45.1 -25.2   7.5
             Cerebellum      21648   43300  -0.8  53.8 -68.3  -8.4 -75.6 -13.8
             Cerebellum      21648   43300  -0.8  53.8 -68.3  -8.4 -75.6 -13.8
               Thalamus       3704    7404   0.7  25.4 -12.0  23.5 -17.2   5.6
               Thalamus       3704    7404   0.7  25.4 -12.0  23.5 -17.2   5.6
        Thalamus Proper       3704    7404   0.7  25.4 -12.0  23.5 -17.2   5.6
        Thalamus Proper       3704    7404   0.7  25.4 -12.0  23.5 -17.2   5.6
                Caudate       3242    6488   5.4  21.8   2.0  48.4 -19.3  13.1
                Caudate       3242    6488   5.4  21.8   2.0  48.4 -19.3  13.1
                Putamen       3868    7732  12.5  36.0   3.9  42.6 -26.7   1.1
                Putamen       3868    7732  12.5  36.0   3.9  42.6 -26.7   1.1
               Pallidum       1374    2744  13.4  28.5   7.2  30.3 -19.6  -6.3
               Pallidum       1374    2744  13.4  28.5   7.2  30.3 -19.6  -6.3
            Hippocampus       3752    7500  14.0  38.6 -18.1  17.1 -42.5  -6.7
            Hippocampus       3752    7500  14.0  38.6 -18.1  17.1 -42.5  -6.7
               Amygdala       1458    2912  15.1  33.6  10.8  24.1 -43.2 -22.4
               Amygdala       1458    2912  15.1  33.6  10.8  24.1 -43.2 -22.4
         accumbens area        838    1672   5.2  15.2  26.0  43.5 -25.8 -15.8
              ventraldc       3366    6732   1.1  30.9  -6.0  25.5 -32.4 -12.8
                 vessel        140     276  27.4  32.0  19.4  25.3 -23.4 -20.9
         choroid plexus       2370    4704  -0.5  37.7 -14.7  44.9 -25.9   9.4
           Optic Chiasm        344     696  -6.5   6.0  22.3  27.2 -33.3 -27.3
           cc posterior       1034    2064  -2.8   2.4 -20.1  -1.6  -4.8  14.4
       cc mid posterior        624    1240  -2.7   2.1  -2.2  13.9   7.0  17.7
             cc central        532    1060  -2.7   2.1  14.0  29.5   9.7  18.0
        cc mid anterior        608    1212  -2.7   2.1  29.0  44.5   1.1  14.8
            cc anterior       1006    2008  -2.8   2.6  40.0  57.6 -15.0   5.7
       color_mode n_colors color_digest opacity is_flatmap
        facecolor        1     40605a68       1      FALSE
        facecolor        1     40605a68       1      FALSE
        facecolor        1     fa9a06b0       1      FALSE
        facecolor        1     fa9a06b0       1      FALSE
        facecolor        1     fa9a06b0       1      FALSE
        facecolor        1     fa9a06b0       1      FALSE
        facecolor        1     82a2eb8f       1      FALSE
        facecolor        1     82a2eb8f       1      FALSE
        facecolor        1     c05a8a6d       1      FALSE
        facecolor        1     c05a8a6d       1      FALSE
        facecolor        1     e2060b29       1      FALSE
        facecolor        1     e2060b29       1      FALSE
        facecolor        1     5bb108a8       1      FALSE
        facecolor        1     b20c29bc       1      FALSE
        facecolor        1     b20c29bc       1      FALSE
        facecolor        1     45d88deb       1      FALSE
        facecolor        1     45d88deb       1      FALSE
        facecolor        1     b47f2b74       1      FALSE
        facecolor        1     756ab4b2       1      FALSE
        facecolor        1     a9b715e7       1      FALSE
        facecolor        1     f7cfe829       1      FALSE
        facecolor        1     40605a68       1      FALSE
        facecolor        1     40605a68       1      FALSE
        facecolor        1     fa9a06b0       1      FALSE
        facecolor        1     fa9a06b0       1      FALSE
        facecolor        1     fa9a06b0       1      FALSE
        facecolor        1     fa9a06b0       1      FALSE
        facecolor        1     82a2eb8f       1      FALSE
        facecolor        1     82a2eb8f       1      FALSE
        facecolor        1     c05a8a6d       1      FALSE
        facecolor        1     c05a8a6d       1      FALSE
        facecolor        1     2960ae60       1      FALSE
        facecolor        1     2960ae60       1      FALSE
        facecolor        1     b20c29bc       1      FALSE
        facecolor        1     b20c29bc       1      FALSE
        facecolor        1     45d88deb       1      FALSE
        facecolor        1     45d88deb       1      FALSE
        facecolor        1     b47f2b74       1      FALSE
        facecolor        1     756ab4b2       1      FALSE
        facecolor        1     a9b715e7       1      FALSE
        facecolor        1     64787738       1      FALSE
        facecolor        1     5c6e2031       1      FALSE
        facecolor        1     36c2395a       1      FALSE
        facecolor        1     2ce28dcf       1      FALSE
        facecolor        1     5b40b064       1      FALSE
        facecolor        1     0f09f440       1      FALSE
        facecolor        1     b6b26add       1      FALSE

# cerebellar atlas produces stable mesh layout

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
             name n_vertices n_faces x_min x_max y_min y_max z_min z_max  color_mode
       cerebellum      30013   57665 -53.6    56 -91.7     0 -64.6     0 vertexcolor
       n_colors color_digest opacity is_flatmap
              3     8690aed8       1      FALSE

# cortical + glassbrain composes as expected

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
                    name n_vertices n_faces x_min x_max  y_min y_max z_min z_max
        glass brain left      10242   20480   -83   0.0 -108.0 108.0 -72.9  73.0
       glass brain right      10242   20480     0  81.8 -107.7 107.7 -73.3  73.3
           left inflated      10242   20480   -83   0.0 -108.0 108.0 -72.9  73.0
          right inflated      10242   20480     0  81.8 -107.7 107.7 -73.3  73.3
        color_mode n_colors color_digest opacity is_flatmap
       vertexcolor        1     19986245     0.2      FALSE
       vertexcolor        1     19986245     0.2      FALSE
       vertexcolor       36     e4a6ca19     1.0      FALSE
       vertexcolor       36     e4a6ca19     1.0      FALSE

# aseg + glassbrain composes as expected

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
                    name n_vertices n_faces x_min x_max  y_min y_max z_min z_max
        glass brain left      10242   20480 -83.0   0.0 -108.0 108.0 -72.9  73.0
       glass brain right      10242   20480   0.0  81.8 -107.7 107.7 -73.3  73.3
              Cerebellum      21232   42456 -53.2   0.7  -68.1  -8.5 -75.4 -13.9
              Cerebellum      21232   42456 -53.2   0.7  -68.1  -8.5 -75.4 -13.9
                Thalamus       3726    7448 -26.7  -0.6  -12.1  22.5 -18.3   5.2
                Thalamus       3726    7448 -26.7  -0.6  -12.1  22.5 -18.3   5.2
         Thalamus Proper       3726    7448 -26.7  -0.6  -12.1  22.5 -18.3   5.2
         Thalamus Proper       3726    7448 -26.7  -0.6  -12.1  22.5 -18.3   5.2
                 Caudate       3026    6056 -21.7  -6.7    1.7  49.1 -20.5  11.8
                 Caudate       3026    6056 -21.7  -6.7    1.7  49.1 -20.5  11.8
                 Putamen       3994    7984 -36.7 -12.4    2.8  42.4 -26.8   1.1
                 Putamen       3994    7984 -36.7 -12.4    2.8  42.4 -26.8   1.1
                Pallidum       1444    2884 -28.2 -12.3    6.8  30.5 -20.4  -6.9
                Pallidum       1444    2884 -28.2 -12.3    6.8  30.5 -20.4  -6.9
              Brain Stem       9214   18424 -16.9  17.4  -25.0  10.4 -82.2 -12.4
             Hippocampus       3782    7560 -37.7 -12.7  -18.2  17.5 -42.7  -7.5
             Hippocampus       3782    7560 -37.7 -12.7  -18.2  17.5 -42.7  -7.5
                Amygdala       1418    2832 -33.0 -14.6   10.0  23.5 -42.6 -22.5
                Amygdala       1418    2832 -33.0 -14.6   10.0  23.5 -42.6 -22.5
          accumbens area        862    1720 -15.2  -5.3   27.0  42.4 -26.6 -14.8
               ventraldc       3366    6732 -29.6   1.0   -6.2  25.2 -33.1 -14.1
                  vessel        152     300 -30.8 -25.2   19.3  24.3 -23.4 -20.8
          choroid plexus       1762    3540 -35.9   0.2  -15.1  45.1 -25.2   7.5
              Cerebellum      21648   43300  -0.8  53.8  -68.3  -8.4 -75.6 -13.8
              Cerebellum      21648   43300  -0.8  53.8  -68.3  -8.4 -75.6 -13.8
                Thalamus       3704    7404   0.7  25.4  -12.0  23.5 -17.2   5.6
                Thalamus       3704    7404   0.7  25.4  -12.0  23.5 -17.2   5.6
         Thalamus Proper       3704    7404   0.7  25.4  -12.0  23.5 -17.2   5.6
         Thalamus Proper       3704    7404   0.7  25.4  -12.0  23.5 -17.2   5.6
                 Caudate       3242    6488   5.4  21.8    2.0  48.4 -19.3  13.1
                 Caudate       3242    6488   5.4  21.8    2.0  48.4 -19.3  13.1
                 Putamen       3868    7732  12.5  36.0    3.9  42.6 -26.7   1.1
                 Putamen       3868    7732  12.5  36.0    3.9  42.6 -26.7   1.1
                Pallidum       1374    2744  13.4  28.5    7.2  30.3 -19.6  -6.3
                Pallidum       1374    2744  13.4  28.5    7.2  30.3 -19.6  -6.3
             Hippocampus       3752    7500  14.0  38.6  -18.1  17.1 -42.5  -6.7
             Hippocampus       3752    7500  14.0  38.6  -18.1  17.1 -42.5  -6.7
                Amygdala       1458    2912  15.1  33.6   10.8  24.1 -43.2 -22.4
                Amygdala       1458    2912  15.1  33.6   10.8  24.1 -43.2 -22.4
          accumbens area        838    1672   5.2  15.2   26.0  43.5 -25.8 -15.8
               ventraldc       3366    6732   1.1  30.9   -6.0  25.5 -32.4 -12.8
                  vessel        140     276  27.4  32.0   19.4  25.3 -23.4 -20.9
          choroid plexus       2370    4704  -0.5  37.7  -14.7  44.9 -25.9   9.4
            Optic Chiasm        344     696  -6.5   6.0   22.3  27.2 -33.3 -27.3
            cc posterior       1034    2064  -2.8   2.4  -20.1  -1.6  -4.8  14.4
        cc mid posterior        624    1240  -2.7   2.1   -2.2  13.9   7.0  17.7
              cc central        532    1060  -2.7   2.1   14.0  29.5   9.7  18.0
         cc mid anterior        608    1212  -2.7   2.1   29.0  44.5   1.1  14.8
             cc anterior       1006    2008  -2.8   2.6   40.0  57.6 -15.0   5.7
        color_mode n_colors color_digest opacity is_flatmap
       vertexcolor        1     19986245    0.15      FALSE
       vertexcolor        1     19986245    0.15      FALSE
         facecolor        1     40605a68    1.00      FALSE
         facecolor        1     40605a68    1.00      FALSE
         facecolor        1     fa9a06b0    1.00      FALSE
         facecolor        1     fa9a06b0    1.00      FALSE
         facecolor        1     fa9a06b0    1.00      FALSE
         facecolor        1     fa9a06b0    1.00      FALSE
         facecolor        1     82a2eb8f    1.00      FALSE
         facecolor        1     82a2eb8f    1.00      FALSE
         facecolor        1     c05a8a6d    1.00      FALSE
         facecolor        1     c05a8a6d    1.00      FALSE
         facecolor        1     e2060b29    1.00      FALSE
         facecolor        1     e2060b29    1.00      FALSE
         facecolor        1     5bb108a8    1.00      FALSE
         facecolor        1     b20c29bc    1.00      FALSE
         facecolor        1     b20c29bc    1.00      FALSE
         facecolor        1     45d88deb    1.00      FALSE
         facecolor        1     45d88deb    1.00      FALSE
         facecolor        1     b47f2b74    1.00      FALSE
         facecolor        1     756ab4b2    1.00      FALSE
         facecolor        1     a9b715e7    1.00      FALSE
         facecolor        1     f7cfe829    1.00      FALSE
         facecolor        1     40605a68    1.00      FALSE
         facecolor        1     40605a68    1.00      FALSE
         facecolor        1     fa9a06b0    1.00      FALSE
         facecolor        1     fa9a06b0    1.00      FALSE
         facecolor        1     fa9a06b0    1.00      FALSE
         facecolor        1     fa9a06b0    1.00      FALSE
         facecolor        1     82a2eb8f    1.00      FALSE
         facecolor        1     82a2eb8f    1.00      FALSE
         facecolor        1     c05a8a6d    1.00      FALSE
         facecolor        1     c05a8a6d    1.00      FALSE
         facecolor        1     2960ae60    1.00      FALSE
         facecolor        1     2960ae60    1.00      FALSE
         facecolor        1     b20c29bc    1.00      FALSE
         facecolor        1     b20c29bc    1.00      FALSE
         facecolor        1     45d88deb    1.00      FALSE
         facecolor        1     45d88deb    1.00      FALSE
         facecolor        1     b47f2b74    1.00      FALSE
         facecolor        1     756ab4b2    1.00      FALSE
         facecolor        1     a9b715e7    1.00      FALSE
         facecolor        1     64787738    1.00      FALSE
         facecolor        1     5c6e2031    1.00      FALSE
         facecolor        1     36c2395a    1.00      FALSE
         facecolor        1     2ce28dcf    1.00      FALSE
         facecolor        1     5b40b064    1.00      FALSE
         facecolor        1     0f09f440    1.00      FALSE
         facecolor        1     b6b26add    1.00      FALSE

# cerebellar + glassbrain composes as expected

    Code
      print(widget_summary(p), row.names = FALSE)
    Output
                    name n_vertices n_faces x_min x_max  y_min y_max z_min z_max
        glass brain left      10242   20480 -83.0   0.0 -108.0 108.0 -72.9  73.0
       glass brain right      10242   20480   0.0  81.8 -107.7 107.7 -73.3  73.3
              cerebellum      30013   57665 -53.6  56.0  -91.7   0.0 -64.6   0.0
        color_mode n_colors color_digest opacity is_flatmap
       vertexcolor        1     19986245    0.15      FALSE
       vertexcolor        1     19986245    0.15      FALSE
       vertexcolor        3     8690aed8    1.00      FALSE

