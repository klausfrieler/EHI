#' Demo EHT
#'
#' This function launches a demo for the EHT.
#'
#' @param num_items (Integer scalar) Number of items in the test.
#' @param feedback (Function) Defines the feedback to give the participant
#' at the end of the test. Defaults to a graph-based feedback page.
#' @param admin_password (Scalar character) Password for accessing the admin panel.
#' Defaults to \code{"demo"}.
#' @param researcher_email (Scalar character)
#' If not \code{NULL}, this researcher's email address is displayed
#' at the bottom of the screen so that online participants can ask for help.
#' Defaults to \email{longgoldstudy@gmail.com},
#' the email address of this package's developer.
#' @param dict The psychTestR dictionary used for internationalisation.
#' @param language The language you want to run your demo in.
#' Possible languages include English (\code{"en"}), German (\code{"de"}), and formal German (\code{"de_f"}).
#' The first language is selected by default
#' @param ... Further arguments to be passed to \code{\link{EHT}()}.
#' @export
#'
EHT_demo <- function(num_items = 3L,
                     feedback = EHT::EHT_feedback_with_score(),
                     admin_password = "demo",
                     researcher_email = "longgoldstudy@gmail.com",
                     dict = EHT::EHT_dict,
                     language = "en",
                     ...) {
  elts <- psychTestR::join(
    EHT_welcome_page(dict = dict),
    EHT::EHT(num_items = num_items,
             with_welcome = FALSE,
             feedback = feedback,
             dict = dict,
             ...),
      EHT_final_page(dict = dict)
  )
  title <- lapply(EHI_languages, function(x) psychTest$translate("TESTNAME", x)) %>% set_name(EHI_languages)
  psychTestR::make_test(
    elts,
    opt = psychTestR::test_options(title = title,
                                   admin_password = admin_password,
                                   researcher_email = researcher_email,
                                   demo = TRUE,
                                   languages = tolower(language)))
}
