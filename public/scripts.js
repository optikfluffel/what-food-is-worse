$(document).ready(function () {
  // foo
  var SLIDE_TEMPO = 500;

  // auto active
  $('a[href="' + this.location.pathname + '"]').parent().addClass('active');

  // init popovers
  $('body').popover({
    selector: '[data-toggle=popover]',
    container: 'body'
  });

  function enableFancyLoginAndRegisterNavbarForm(type) {
    // show
    $('.toggle-forms a.' + type).click(function(event) {
      event.preventDefault();
      $(this).parents('.toggle-forms').hide();
      $('.navbar-form.' + type).show();
      $('.navbar-form.' + type).find('input[name="username"]').focus();
    });

    // cancel
    $('.navbar-form.' + type + ' .reset').click(function(event) {
      $(this).parents('.navbar-form').hide();
      $('#main-nav .toggle-forms').show();
    });
  }

  enableFancyLoginAndRegisterNavbarForm('login');
  enableFancyLoginAndRegisterNavbarForm('register');

  function initializeNewGameRound(newGame) {
    // deconstruct newGame
    var newGameId = newGame.id;
    var newQuestion = newGame.question;
    var newChoices = newGame.products;

    // get elements
    var $wrapper = $('#fiftycent');
    var $question = $('.question.row').children('h1');
    var $products = $('.products.row');
    var $choices = $products.children('.game-link');

    // update question
    var $smallQuestionExtension = $('<small />').text('auf 100g');
    $question.text(newQuestion).append($smallQuestionExtension);

    // update choices
    $choices.each(function(index) {
      var newChoice = $.parseJSON(newChoices[index]);
      var newChoiceId = newChoice.id;

      $(this).data('game', newGameId);
      $(this).data('id', newChoiceId);

      $image = $(this).children('img');
      $image.slideUp(SLIDE_TEMPO, function() {
        $(this).attr('src', newChoice.imgurl)
               .attr('alt', newChoice.name)
               .delay(500)
               .slideDown(SLIDE_TEMPO);
      })

      $name = $(this).children('h3');
      $name.slideUp(SLIDE_TEMPO, function() {
        $(this).text(newChoice.name)
               .delay(500)
               .slideDown(SLIDE_TEMPO);
      })
    })
  }

  function showAlert(message, type) {
    $messages = $('#messages');

    $alert = $('<div />').addClass('alert')
                         .addClass('alert-' + type)
                         .attr('role', 'alert')
                         .text(message)
                         .hide();

    $alert.appendTo($messages).slideDown(SLIDE_TEMPO, function() {
      $.getJSON('/json/play', initializeNewGameRound);

      $(this).delay(1000).slideUp(SLIDE_TEMPO, function() { $(this).remove(); });
    });
  }

  $(".alert").alert() // enable alert dismissing

  function handlePlayAPIAnswer(data) {
    var answer = $.parseJSON(data);

    if (answer.correct === true) {
      showAlert('YAY! Das war richtig!', 'success');
    } else {
      showAlert('Och menno, gib dir doch mal etwas mehr Mühe..', 'danger');
    }
  }

  function enableEvenFancierGameLinksSoYouCanActuallyPlayNow($link) {
    $link.click(function(event) {
      event.preventDefault();

      var gameId = $link.data('game');
      var id = $link.data('id');

      var answer = {
        game: gameId,
        guess: id
      };

      $.post('/play', answer).done(handlePlayAPIAnswer);
    });
  }

  $('.game-link').each(function() {
    enableEvenFancierGameLinksSoYouCanActuallyPlayNow($(this));
  });
});
