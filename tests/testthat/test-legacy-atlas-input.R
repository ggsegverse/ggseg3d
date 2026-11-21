# Every fixture elsewhere in this suite is a current `ggseg_atlas` object, so
# nothing here used to exercise the representation all 32 atlas packages still
# ship: the pre-3.0.0 tagged list. `as_legacy_list_atlas()` degrades a current
# atlas back to that shape, and these tests drive one through every public
# entry point that takes an atlas, asserting the result is not merely
# error-free but *identical* to the object's own.

legacy_cases <- list(
  cortical = list(atlas = dk(), args = list(hemisphere = "left")),
  subcortical = list(atlas = aseg(), args = list()),
  tract = list(atlas = tracula(), args = list()),
  cerebellar = list(atlas = make_test_cerebellar_atlas(), args = list())
)

describe("ggseg3d() accepts a legacy list atlas", {
  for (type in names(legacy_cases)) {
    local({
      case <- legacy_cases[[type]]
      it(paste("renders a", type, "atlas identically to its S7 form"), {
        from_s7 <- do.call(ggseg3d, c(list(atlas = case$atlas), case$args))
        from_legacy <- do.call(
          ggseg3d,
          c(list(atlas = as_legacy_list_atlas(case$atlas)), case$args)
        )

        expect_s3_class(from_legacy, "ggseg3d")
        expect_identical(from_legacy$x, from_s7$x)
      })
    })
  }

  it("upgrades without printing anything", {
    expect_silent(ggseg3d(atlas = as_legacy_list_atlas(aseg())))
  })

  it("still reports a non-atlas and a structurally broken atlas", {
    broken <- as_legacy_list_atlas(aseg())
    broken$core$label <- NULL

    expect_error(ggseg3d(atlas = list()), class = "ggseg.formats_not_atlas")
    expect_error(
      ggseg3d(atlas = broken),
      class = "ggseg.formats_invalid_atlas"
    )
  })
})

describe("ggsegray() accepts a legacy list atlas", {
  it("builds the same rgl meshes and legend as the S7 atlas", {
    skip_if_not_installed("rgl")

    from_s7 <- ggsegray(atlas = aseg())
    from_legacy <- ggsegray(atlas = as_legacy_list_atlas(aseg()))
    rgl::close3d()
    rgl::close3d()

    expect_identical(from_legacy$meshes, from_s7$meshes)
    expect_identical(from_legacy$legend_data, from_s7$legend_data)
  })

  it("renders a legacy cortical atlas", {
    skip_if_not_installed("rgl")

    from_s7 <- ggsegray(atlas = dk(), hemisphere = "left")
    from_legacy <- ggsegray(
      atlas = as_legacy_list_atlas(dk()),
      hemisphere = "left"
    )
    rgl::close3d()
    rgl::close3d()

    expect_identical(from_legacy$meshes, from_s7$meshes)
  })

  it("still reports a non-atlas", {
    skip_if_not_installed("rgl")

    expect_error(ggsegray(atlas = list()), class = "ggseg.formats_not_atlas")
  })
})

describe("add_atlas() accepts a legacy list atlas", {
  host <- function() ggseg3d(atlas = dk(), hemisphere = "left")

  it("adds a legacy atlas identically to its S7 form", {
    from_s7 <- add_atlas(host(), aseg())
    from_legacy <- add_atlas(host(), as_legacy_list_atlas(aseg()))

    expect_identical(from_legacy$x, from_s7$x)
  })

  it("passes type-specific arguments through for a legacy atlas", {
    from_s7 <- add_atlas(host(), dk(), hemisphere = "right")
    from_legacy <- add_atlas(
      host(),
      as_legacy_list_atlas(dk()),
      hemisphere = "right"
    )

    expect_identical(from_legacy$x, from_s7$x)
  })

  it("still reports a non-atlas", {
    expect_error(
      add_atlas(host(), list()),
      class = "ggseg.formats_not_atlas"
    )
  })
})

# `prepare_brain_meshes()` dispatches on the atlas subclass tag, which a
# legacy list carries verbatim, so it reaches the right method with no door of
# its own. Asserted here because that is the reason the generic is left
# untouched: were dispatch to fall through to the `default` method, the three
# entry points above would be masking an abort.
describe("prepare_brain_meshes() dispatch on a legacy list", {
  for (type in names(legacy_cases)) {
    local({
      case <- legacy_cases[[type]]
      it(paste("reaches the", type, "method"), {
        legacy <- as_legacy_list_atlas(case$atlas)

        prepared <- do.call(
          prepare_brain_meshes,
          c(
            list(
              atlas = legacy,
              .data = NULL,
              label_by = "region",
              text_by = NULL,
              colour_by = "colour",
              palette = NULL,
              na_colour = "darkgrey",
              na_alpha = 1
            ),
            case$args
          )
        )

        expect_named(prepared, c("meshes", "legend_data"))
        expect_gt(length(prepared$meshes), 0L)
      })
    })
  }
})
