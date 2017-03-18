#' Clean the anforandetext in the corpus file
#'
#' @description 
#' These functions contain all preprocessing of corpus text.
#'
#' @param anforandetext a character vector from anforandetext in corpus file
#' @keywords Internal
anforandetext_clean <- function(anforandetext){
  checkmate::assert_character(anforandetext)
  
  anforandetext <- anforandetext_clean_basic(anforandetext)
  anforandetext <- anforandetext_clean_correct_errors(anforandetext)
  anforandetext <- anforandetext_clean_remove_greetings(anforandetext)
  anforandetext <- tolower(anforandetext)
  anforandetext <- stringr::str_replace_all(anforandetext, "\\(.*\\)", " ") # Remove paranthesis
  anforandetext <- anforandetext_clean_handle_digits(anforandetext)
  anforandetext <- anforandetext_clean_symbols(anforandetext)
  anforandetext <- anforandetext_clean_punctuation(anforandetext)
  anforandetext <- anforandetext_clean_punctuation(anforandetext)
  
  # Final trimming of space
  anforandetext <- stringr::str_replace_all(anforandetext, "[:space:]+", " ")
  anforandetext <- stringr::str_trim(anforandetext)
  
  anforandetext
}

#' @rdname anforandetext_clean
anforandetext_clean_basic <- function(anforandetext){
  checkmate::assert_character(anforandetext)
  # Remove bindesstreck due to errors
  anforandetext <- stringr::str_replace_all(anforandetext, "-\n|-\r\n", "")
  # Replace \n\r with space
  anforandetext <- stringr::str_replace_all(anforandetext, "\n|\r", " ")
  
  # Remove paragraphs
  anforandetext <- stringr::str_replace_all(anforandetext, "<[//]?p>", " ")
  
  # Remove em signs
  anforandetext <- stringr::str_replace_all(anforandetext, "<[//]?em>", " ")
  
  # Remove kantrubriker
  kantrubrik_regexp <- "(STYLEREF)(.*?)(MERGEFORMAT)[ ]*(.*?)[ ]{2}"
  check_kantrubrik <- stringr::str_extract_all(anforandetext, kantrubrik_regexp)
  anforandetext <- stringr::str_replace_all(anforandetext, kantrubrik_regexp, " ")
 
  anforandetext 
}
  
#' @rdname anforandetext_clean
anforandetext_clean_correct_errors <- function(anforandetext){
  checkmate::assert_character(anforandetext)
  # Small corrections in text
  anforandetext <- stringr::str_replace_all(anforandetext,
                         "Fru talman1", 
                         "Fru talman!")
  anforandetext <- stringr::str_replace_all(anforandetext,
                         "Fru talman Efter att ha lyssnat på Barbro Feltzing",
                         "Fru talman! Efter att ha lyssnat på Barbro Feltzing")
  anforandetext <- stringr::str_replace_all(anforandetext, 
                         "Herr talman Alltfler röster höjs för en tvångsdelning", 
                         "Herr talman! Alltfler röster höjs för en tvångsdelning")
  anforandetext <- stringr::str_replace_all(anforandetext,
                         "Herr talman:",
                         "Herr talman!")
  anforandetext <- stringr::str_replace_all(anforandetext,
                         "Fru talman Det är väl angeläget att vi är alldeles klara",
                         "Fru talman! Det är väl angeläget att vi är alldeles klara")
  anforandetext <- stringr::str_replace_all(anforandetext,
                         "Fru talman Det är väl angeläget att vi är alldeles klara",
                         "Fru talman! Det är väl angeläget att vi är alldeles klara")
  anforandetext <- stringr::str_replace_all(anforandetext,
                         "Herr talman Vad gäller målet för vår jobbpolitik",
                         "Herr talman! Vad gäller målet för vår jobbpolitik")
  anforandetext <- stringr::str_replace_all(anforandetext,
                         "Fru talman Jag beskrev inte vad som låg bakom regeringens agerande för",
                         "Fru talman! Jag beskrev inte vad som låg bakom regeringens agerande för")
  
  # Exceptional handling
  anforandetext <- stringr::str_replace_all(anforandetext,
                         "Herr talman Tobias Billström har frågat mig vilka initiativ",
                         "Herr_talman Tobias Billström har frågat mig vilka initiativ")
  anforandetext <- stringr::str_replace_all(anforandetext,
                         "Herr talman, barnens arbetsmiljö i förskola, skola och skolbarnsomsorg",
                         "Herr_talman, barnens arbetsmiljö i förskola, skola och skolbarnsomsorg")
  anforandetext
}


#' @rdname anforandetext_clean
anforandetext_clean_remove_greetings <- function(anforandetext){
  
  greet0 <- "^( )*?([Hh]err|[Ff]ru)( )*?(talman|ålderspresident).*?(!|\\.|\\?)"
  check_greet0 <- stringr::str_extract(anforandetext, greet0)
  anforandetext <- stringr::str_replace_all(anforandetext, greet0, " ")
  
  greet2 <- "^( )*?(replik|plik)( )*?([Hh]err|[Ff]ru)( )*?(talman)( )*?(!)?"
  check_greet2 <- stringr::str_extract(anforandetext, greet2)
  anforandetext <- stringr::str_replace_all(anforandetext, greet2, " ")
  
  greet3 <- "^( )*?(Svar på interpellationer)( )*?([Hh]err|[Ff]ru)( )*?(talman)( )*?(!)?"
  check_greet3 <- stringr::str_extract(anforandetext, greet3)
  anforandetext <- stringr::str_replace_all(anforandetext, greet3, " ")
  
  greet4 <- "^( )*?(Ärade)( )*?[A-Za-z]*(ledamöter)( )*?!"
  check_greet4 <- stringr::str_extract(anforandetext, greet4)
  anforandetext <- stringr::str_replace_all(anforandetext, greet4, " ")
  
  greet5 <- "^( )*?(Ärade)( )*?[A-Za-z]*(ledamöter).*?(!|\\.)"
  check_greet5 <- stringr::str_extract(anforandetext, greet5)
  anforandetext <- stringr::str_replace_all(anforandetext, greet5, " ")
  
  anforandetext
}

#' @rdname anforandetext_clean
anforandetext_clean_handle_digits <- function(anforandetext){

  # Handle digits
  anforandetext <- stringr::str_replace_all(anforandetext, "[12][:digit:]{3}(\\/)[12][:digit:]{1,3}", "YYYY")
  anforandetext <- stringr::str_replace_all(anforandetext, "(1)[:digit:]{3}|(20)[:digit:]{2}", "YYYY")
  anforandetext <- stringr::str_replace_all(anforandetext, "[:digit:][:punct:][:digit:]", "N_N")
  anforandetext <- stringr::str_replace_all(anforandetext, "[:digit:]", "N")
  anforandetext <- stringr::str_replace_all(anforandetext, "½", " N_N ")
  anforandetext <- stringr::str_replace_all(anforandetext, "¼", " N_N ")
  anforandetext
}

#' @rdname anforandetext_clean
anforandetext_clean_symbols <- function(anforandetext){

  # Write out symbols
  anforandetext <- stringr::str_replace_all(anforandetext, "\\%", " procent ")
  anforandetext <- stringr::str_replace_all(anforandetext, "\\+", " plus ")
  anforandetext <- stringr::str_replace_all(anforandetext, "\\=", " lika_med ")
  anforandetext <- stringr::str_replace_all(anforandetext, "\\±", " plus_minus ")
  
  ## Remove special symbols/citations
  anforandetext <- stringr::str_replace_all(anforandetext, "\\`|\\´|\\¹", " ")
  
  # Remove apostophes
  anforandetext <- stringr::str_replace_all(anforandetext, "à|á", "a")
  anforandetext <- stringr::str_replace_all(anforandetext, "é|è", "e")
  anforandetext <- stringr::str_replace_all(anforandetext, "ó|ò", "o")
  
  
  anforandetext
}


#' @rdname anforandetext_clean
anforandetext_clean_punctuation <- function(anforandetext){
  checkmate::assert_character(anforandetext)
  ## Handle punctuations
  # anforandetext <- stringr::str_replace_all(anforandetext, "[:punct:]", " ")
  
  # Handle :
  anforandetext <- stringr::str_replace_all(anforandetext, " s:t ", " st ") # Special
  remove <- "s|n|are|en|et|erna|ar|ars|arna|andet|ande|at|ad|ade|er|ares|ns|ares|na|arnas|arnas|or|ans|as|a|orna|an|aren|ens|aren|erier|eriet|ets|e|t"
  anforandetext <- stringr::str_replace_all(anforandetext, paste0(":(",remove, ")( |$)"), "")
  
  # Handle .
  # Handle . in web adresses
  anforandetext <- stringr::str_replace_all(anforandetext, "([:alpha:]+)(\\.)(com|dk|nu|se|org|net|fi|no)" , "\\1_\\3")
  
  # Handle common abbrv (with .)
  anforandetext <- stringr::str_replace_all(anforandetext, " t\\.ex ", " t_ex ")    
  anforandetext <- stringr::str_replace_all(anforandetext, " bl\\.a ", " bl_a ")
  anforandetext <- stringr::str_replace_all(anforandetext, " m\\.m", " m_m")
  anforandetext <- stringr::str_replace_all(anforandetext, " s\\.k ", " s_k ")    
  anforandetext <- stringr::str_replace_all(anforandetext, " t\\.o\\.m", " t_o_m")
  anforandetext <- stringr::str_replace_all(anforandetext, " t\\.om", " t_o_m")
  anforandetext <- stringr::str_replace_all(anforandetext, " fr\\.o\\.m", " fr_o_m")
  anforandetext <- stringr::str_replace_all(anforandetext, " fr\\.om", " fr_o_m")
  anforandetext <- stringr::str_replace_all(anforandetext, " m\\.fl", " m_fl")
  anforandetext <- stringr::str_replace_all(anforandetext, " f\\.d", " f_d")
  anforandetext <- stringr::str_replace_all(anforandetext, " o\\.d", " o_d")
  anforandetext <- stringr::str_replace_all(anforandetext, " e\\.d", " e_d")
  
  # Handle other punctuations
  # anforandetext <- stringr::str_replace_all(anforandetext, "[.?!&,;'/\]", " ")
  anforandetext <- stringr::str_replace_all(anforandetext, "[:punct:]", " ")
  
  anforandetext
}

