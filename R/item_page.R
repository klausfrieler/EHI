media_js <- list(
  media_not_played = "var media_played = false;",
  media_played = "media_played = true;",
  play_media = "document.getElementById('media').play();",
  show_media   = paste0("if (!media_played) ",
                        "{document.getElementById('media')",
                        ".style.visibility='inherit'};"),
  hide_media   = paste0("if (media_played) ",
                          "{document.getElementById('media')",
                          ".style.visibility='hidden'};"),
  show_media_btn = paste0("if (!media_played) ",
                          "{document.getElementById('btn_play_media')",
                          ".style.visibility='inherit'};"),
  hide_media_btn = paste0("document.getElementById('btn_play_media')",
                          ".style.visibility='hidden';"),
  show_responses = "document.getElementById('response_ui').style.visibility = 'inherit';"
)

#media_mobile_play_button <- shiny::tags$button(
#  shiny::tags$strong(psychTestR::i18n("CLICK_HERE_TO_PLAY")),
#  id = "btn_play_media",
#  style = "visibility: visible;height: 50px",
#  onclick = media_js$play_media
#)

media_mobile_play_button <- shiny::tags$p(
  shiny::tags$button(shiny::tags$span("\u25B6"),
                     type = "button",
                     id = "btn_play_media",
                     style = "visibility: hidden",
                     onclick = media_js$play_media)
)

get_audio_ui <- function(url,
                         type = tools::file_ext(url),
                         autoplay = TRUE,
                         width = 0,
                         wait = TRUE,
                         loop = FALSE) {
  #print(url)
  stopifnot(purrr::is_scalar_character(url),
            purrr::is_scalar_character(type),
            purrr::is_scalar_logical(wait),
            purrr::is_scalar_logical(loop))
  src    <- shiny::tags$source(src = url, type = paste0("audio/", type))
  script <- shiny::tags$script(shiny::HTML(media_js$media_not_played))
  audio  <- shiny::tags$audio(
    script,
    src,
    id = "media",
    preload = "auto",
    autoplay = if(autoplay) "autoplay",
    width = width,
    loop = if (loop) "loop",
    oncanplaythrough = media_js$show_media_btn,
    onplay = paste0(media_js$media_played, media_js$hide_media_btn),
    #onended = if (wait) paste0(media_js$show_responses, media_js$hide_media) else "null",
    onended = if (wait) media_js$show_responses else "null"
  )
  shiny::tags$div(audio, media_mobile_play_button)
}

get_audio_element <- function(url,
                              type = tools::file_ext(url),
                              wait = F,
                              autoplay = FALSE,
                              width = 200,
                              height = 50,
                              id = "media") {
  #print(url)
  stopifnot(purrr::is_scalar_character(url),
            purrr::is_scalar_character(type)
            )
  src    <- shiny::tags$source(src = url, type = paste0("audio/", type))
  script <- shiny::tags$script(shiny::HTML(media_js$media_not_played))
  audio  <- shiny::tags$audio(
    src,
    script,
    id = id,
    preload = "auto",
    controls = "controls",
    controlslist = "nodownload noremoteplayback",
    autoplay = if(autoplay) "autoplay",
    width = width,
    height = height,
    onplay = paste0(media_js$media_played, media_js$hide_media),
    onended = if (wait) paste0(media_js$show_responses, media_js$hide_media) else "null"
  )
  audio
}

audio_NAFC_page_flex <- function(label,
                                 prompt,
                                 choices,
                                 labels,
                                 audio_url,
                                 correct_answer,
                                 save_answer = TRUE,
                                 get_answer = NULL,
                                 on_complete = NULL,
                                 admin_ui = NULL) {
  #browser()
  stopifnot(purrr::is_scalar_character(label))
  audio_ui <- get_audio_ui(audio_url, wait = T, loop = F, width = 200)
  style <- NULL
  ui <- shiny::div(
    tagify(prompt),
    audio_ui,
    psychTestR::make_ui_NAFC(
      choices,
      labels = labels,
      hide = TRUE,
      arrange_vertically = FALSE,
      id = "response_ui")
  )
  get_answer <- function(input, ...) {
    #browser()
    #answer <- as.numeric(gsub("answer", "", input$last_btn_pressed))
    answer <- input$last_btn_pressed
    correct <- EHI::EHI_item_bank[EHI::EHI_item_bank$item_number == label,]$emotion == answer

    # messagef("[%s] Label: %s, Correct: %s, answer: %s",
    #          audio_url,
    #          label,
    #          EHI::EHI_item_bank[EHI::EHI_item_bank$item_number == label,]$emotion,
    #          answer)
    tibble(answer = answer,
           label = label,
           correct = correct)
  }
  validate <- function(answer, ...) !is.null(answer)
  psychTestR::page(ui = ui, label = label,
                   get_answer = get_answer, save_answer = save_answer,
                   validate = validate, on_complete = on_complete,
                   final = FALSE,
                   admin_ui = admin_ui)
}

EHI_item <- function(label = "",
                     audio_file,
                     correct_answer,
                     prompt = "",
                     audio_dir = "",
                     save_answer = TRUE,
                     on_complete = NULL,
                     get_answer = NULL,
                     instruction_page = FALSE
                     ){
  #browser()
  page_prompt <- shiny::div(prompt)
  choices <- c("angry", "happy", "sad")
  labels <- lapply(na.omit(unique(EHI::EHI_item_bank$task_group)), psychTestR::i18n)
  audio_url <- file.path(audio_dir, audio_file)
  #print(correct_answer)
  audio_NAFC_page_flex(label = label,
                       prompt = page_prompt,
                       audio_url = audio_url,
                       choices = choices,
                       labels = labels,
                       correct_answer = force(correct_answer),
                       save_answer = save_answer,
                       get_answer = get_answer,
                       on_complete = on_complete)
}

