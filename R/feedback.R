#' EHI feedback (with score)
#'
#' Here the participant is given textual feedback at the end of the test.
#' @param dict The psychTestR dictionary used for internationalisation.
#' @export
#' @examples
#' \dontrun{
#' EHI_demo(feedback = EHI_feedback_with_score())}

EHI_feedback_with_score <- function(dict = EHI::EHI_dict) {
    psychTestR::new_timeline(
      psychTestR::reactive_page(function(state, ...) {
        #browser()
        results <- psychTestR::get_results(state = state,
                                           complete = TRUE,
                                           add_session_info = FALSE) %>% as.list()
        #sum_score <- sum(purrr::map_lgl(results[[1]], function(x) x$correct))
        #num_question <- length(results[[1]])
        #messagef("Sum scores: %d, total items: %d", sum_score, num_question)
        if (is.null(results$EHI$score)) {
          num_correct <- sum(attr(results$EHI$ability, "metadata")$results$score)
          num_question <- nrow(attr(results$EHI$ability, "metadata")$results)
        }
        else {
          num_correct <- round(results$EHI$score * results$EHI$num_question)
          num_question <- nrow(results)
        }
        text_finish <- psychTestR::i18n("COMPLETED",
                                        html = TRUE,
                                        sub = list(num_question = num_question,
                                                   num_correct = num_correct))
        psychTestR::one_button_page(
          body= shiny::div(
            shiny::p(text_finish)
          ),
          button_text = "Continue"
        )
      }
      ),
    dict = dict
  )
}

EHI_feedback_graph_normal_curve <- function(perc_correct, x_min = 40, x_max = 160, x_mean = 100, x_sd = 15) {
  q <-
    ggplot2::ggplot(data.frame(x = c(x_min, x_max)), ggplot2::aes(x)) +
    ggplot2::stat_function(fun = stats::dnorm, args = list(mean = x_mean, sd = x_sd)) +
    ggplot2::stat_function(fun = stats::dnorm, args=list(mean = x_mean, sd = x_sd),
                           xlim = c(x_min, (x_max - x_min) * perc_correct + x_min),
                           fill = "lightblue4",
                           geom = "area")
  q <- q + ggplot2::theme_bw()
  #q <- q + scale_y_continuous(labels = scales::percent, name="Frequency (%)")
  #q <- q + ggplot2::scale_y_continuous(labels = NULL)
  x_axis_lab <- sprintf(" %s %s", psychTestR::i18n("TESTNAME"), psychTestR::i18n("VALUE"))
  title <- psychTestR::i18n("SCORE_TEMPLATE")
  fake_IQ <- (x_max - x_min) * perc_correct + x_min
  main_title <- sprintf("%s: %.0f", title, round(fake_IQ, digits = 0))

  q <- q + ggplot2::labs(x = x_axis_lab, y = "")
  q <- q + ggplot2::ggtitle(main_title)
  plotly::ggplotly(q, width = 600, height = 450)
}
#' EHI feedback (with graph)
#'
#' Here the participant is given textual and graphical feedback at the end of the test.
#' @param dict The psychTestR dictionary used for internationalisation.
#' @export
#' @examples
#' \dontrun{
#' EHI_demo(feedback = EHI_feedback_with_score())}
EHI_feedback_with_graph <- function(dict = EHI::EHI_dict) {
  psychTestR::new_timeline(
      psychTestR::reactive_page(function(state, ...) {
        #browser()
        results <- psychTestR::get_results(state = state,
                                           complete = TRUE,
                                           add_session_info = FALSE) %>% as.list()

        #sum_score <- sum(purrr::map_lgl(results[[1]], function(x) x$correct))
        #printf("Sum scores: %d, total items: %d perc_correct: %.2f", sum_score, num_question, perc_correct)
        #browser()
        if (is.null(results$EHI$score)) {
          num_correct <- sum(attr(results$EHI$ability, "metadata")$results$score)
          num_question <- results$EHI$num_items
          perc_correct <- (results$EHI$ability+4)/8
        }
        else {
          num_correct <- round(results$EHI$score * results$EHI$num_questions)
          num_question <- results$EHI$num_questions
          perc_correct <- num_correct/num_question
        }
        text_finish <- psychTestR::i18n("COMPLETED",
                                        html = TRUE,
                                        sub = list(num_question = num_question,
                                                   num_correct = num_correct))
        norm_plot <- EHI_feedback_graph_normal_curve(perc_correct)
        psychTestR::page(
          ui = shiny::div(
            shiny::p(text_finish),
            shiny::p(norm_plot),
            shiny::p(psychTestR::trigger_button("next", psychTestR::i18n("CONTINUE")))
          )
        )
      }
      ),
    dict = dict
  )

}
