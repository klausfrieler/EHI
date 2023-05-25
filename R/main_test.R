scoring <- function(){
  psychTestR::code_block(function(state,...){
    #browser()
    results <- psychTestR::get_results(state = state,
                                       complete = FALSE,
                                       add_session_info = FALSE) %>% as.list()

    sum_score <- sum(purrr::map_lgl(results$EHI, function(x) x$correct))
    num_question <- length(results$EHI)
    perc_correct <- sum_score/num_question
    messagef("EHI: questions: %d, Correct: %d, perc_corrct: %.3f", num_question, sum_score, perc_correct)
    psychTestR::save_result(place = state,
                 label = "score",
                 value = perc_correct)
    psychTestR::save_result(place = state,
                             label = "num_questions",
                             value = num_question)

  })
}

# get_eligible_first_items_EHI <- function(){
#   lower_sd <- mean(EHI::EHI_item_bank$difficulty) - stats::sd(EHI::EHI_item_bank$difficulty)
#   upper_sd <- mean(EHI::EHI_item_bank$difficulty) + stats::sd(EHI::EHI_item_bank$difficulty)
#  which(EHI::EHI_item_bank$difficulty >= lower_sd  &
#          EHI::EHI_item_bank$difficulty <= upper_sd)
# }

get_balanced_sample <- function(max_sets = 4){
  tmp <- EHI::EHI_item_bank %>%
    group_by(emotion, usage) %>%
    mutate(id = 1:n()) %>%
    ungroup() %>%
    filter(usage == "test", id <= max_sets * 4) %>%
    mutate(sid = sprintf("%s_%s_%s", emotion, sentence, speaker),
           sid_ext = sprintf("%s_%s_%s_%s", emotion, sentence, speaker, variant))
  sids <- unique(tmp$sid)
  selection <- sprintf("%s_%s", sids, sample(1:2, length(sids), replace = T))
  tmp %>% filter(sid_ext %in% selection) %>% pull(item_number) %>% sample()

}

main_test <- function(label,
                      item_sequence,
                      audio_dir,
                      dict = EHI::EHI_dict,
                      ...) {
  elts <- c()
  item_bank <- EHI::EHI_item_bank
  #item_sequence <- sample(1:nrow(item_bank), num_items)
  # not_good <- TRUE
  # while(not_good){
  #   messagef("Sampling...")
  #   item_sequence <- get_balanced_sample()
  #   not_good <- "sad9" %in% item_sequence
  # }
  # print(item_sequence)
  for(i in 1:length(item_sequence)){
    item <- item_bank %>% filter(item_number %in% item_sequence[i])
    emotion <- psychTestR::i18n(item[1,]$task_group)
    item_page <- EHI_item(label = item_sequence[i],
                          correct_answer =  force(item[1,]$emotion),
                          prompt = get_prompt(i,
                                              length(item_sequence)),
                          audio_file = item$audio_file[1],
                          audio_dir = audio_dir,
                          save_answer = TRUE)
    elts <- psychTestR::join(elts, item_page)
  }
  elts
}


get_prompt <- function(item_number,
                       num_items,
                       dict = EHI::EHI_dict) {
  shiny::div(
    shiny::h4(
      psychTestR::i18n(
        "PROGRESS_TEXT",
        sub = list(num_question = item_number,
                   test_length = if (is.null(num_items))
                     "?" else
                       num_items)),
      style  = "text_align:left"
    ),
    shiny::p(
      psychTestR::i18n("ITEM_INSTRUCTION"),
      style = "margin-left:20%;margin-right:20%;text-align:justify")
    )
}

EHI_welcome_page <- function(dict = EHI::EHI_dict){
  psychTestR::new_timeline(
    psychTestR::one_button_page(
    body = shiny::div(
      shiny::h4(psychTestR::i18n("WELCOME")),
      shiny::div(psychTestR::i18n("INTRO_TEXT"),
               style = "margin-left:20%;margin-right:20%;width:60%;display:block;text-align:justify")
    ),
    button_text = psychTestR::i18n("CONTINUE")
  ), dict = dict)
}

EHI_finished_page <- function(dict = EHI::EHI_dict){
  psychTestR::new_timeline(
    psychTestR::one_button_page(
      body =  shiny::div(
        shiny::h4(psychTestR::i18n("THANKS")),
        psychTestR::i18n("SUCCESS"),
                         style = "margin-left:0%;display:block"),
      button_text = psychTestR::i18n("CONTINUE")
    ), dict = dict)
}

EHI_final_page <- function(dict = EHI::EHI_dict){
  psychTestR::new_timeline(
    psychTestR::final_page(
      body = shiny::div(
        shiny::h4(psychTestR::i18n("THANKS")),
        shiny::div(psychTestR::i18n("SUCCESS"),
                   style = "margin-left:0%;display:block"),
        button_text = psychTestR::i18n("CONTINUE")
      )
    ), dict = dict)
}

show_item <- function(audio_dir) {
  function(item, ...) {
    #stopifnot(is(item, "item"), nrow(item) == 1L)
    item_number <- psychTestRCAT::get_item_number(item)
    num_items <- psychTestRCAT::get_num_items_in_test(item)
    emotion <- psychTestR::i18n(item[1,]$emotion_i18)
    #messagef("Showing item %s, correct = %s", item_number, item$answer)
    EHI_item(
      label = paste0("q", item_number),
      audio_file = item$audio_file,
      correct_answer = item$emotion,
      adaptive = TRUE,
      prompt = get_prompt(item_number, num_items, emotion),
      audio_dir = audio_dir,
      save_answer = TRUE,
      get_answer = NULL,
      on_complete = NULL,
      instruction_page = FALSE
    )
  }
}
