library(tidyverse)
library(psychTestR)

#printf   <- function(...) print(sprintf(...))
#messagef <- function(...) message(sprintf(...))
#' EHI
#'
#' This function defines a EHI  module for incorporation into a
#' psychTestR timeline.
#' Use this function if you want to include the EHI in a
#' battery of other tests, or if you want to add custom psychTestR
#' pages to your test timeline.
#'
#' For demoing the EHI, consider using \code{\link{EHI_demo}()}.
#' For a standalone implementation of the EHI,
#' consider using \code{\link{EHI_standalone}()}.
#' @param num_items (Integer scalar) Number of items in the test.
#' @param with_welcome (Scalar boolean) Indicates, if a welcome page shall be displayed. Defaults to TRUE
#' @param take_training (Logical scalar) Whether to include the training phase. Defaults to FALSE
#' @param with_finish (Scalar boolean) Indicates, if a finish (not final!) page shall be displayed. Defaults to TRUE
#' @param label (Character scalar) Label to give the EHI results in the output file.
#' @param feedback (Function) Defines the feedback to give the participant
#' at the end of the test.
#' @param dict The psychTestR dictionary used for internationalisation.
#' @export

EHI <- function(num_items = 24L,
                with_welcome = FALSE,
                take_training = FALSE,
                with_finish = FALSE,
                label = "EHI",
                feedback = EHI_feedback_with_score(),
                dict = EHI::EHI_dict
                ) {
  audio_dir <- "https://media.gold-msi.org/test_materials/EHI"
  stopifnot(purrr::is_scalar_character(label),
            purrr::is_scalar_integer(num_items) || purrr::is_scalar_double(num_items),
            purrr::is_scalar_character(audio_dir),
            psychTestR::is.timeline(feedback) ||
              is.list(feedback) ||
              psychTestR::is.test_element(feedback) ||
              is.null(feedback))
  audio_dir <- gsub("/$", "", audio_dir)
  not_good <- TRUE
  while(not_good){
    messagef("Sampling...")
    item_sequence <- get_balanced_sample(num_items / 6)
    not_good <- "sad9" %in% item_sequence
  }

  psychTestR::join(
    psychTestR::begin_module(label),
    if (take_training) psychTestR::new_timeline(instructions(audio_dir), dict = dict),
    if (with_welcome) EHI_welcome_page(),
    psychTestR::new_timeline(
      main_test(label = label,
                item_sequence,
                audio_dir = audio_dir,
                dict = dict
                ),
      dict = dict),
    scoring(),
    psychTestR::elt_save_results_to_disk(complete = TRUE),
    feedback,
    if(with_finish) EHI_finished_page(),
    psychTestR::end_module())
}
