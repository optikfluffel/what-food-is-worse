$(document).ready(function () {
  // auto active
  $('a[href="' + this.location.pathname + '"]').parent().addClass('active');

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
      $image.attr('src', newChoice.imgurl)
            .attr('alt', newChoice.name);

      $name = $(this).children('h3');
      $name.text(newChoice.name);
    })
  }

  function handlePlayAPIAnswer(data) {
    var answer = $.parseJSON(data);

    // TODO: show nicer flash messages
    if (answer.correct) {
      alert('YAY! You are totally right!');
    } else {
      alert('Oh no, I am sorry to correct you but it\'s the other way around.');
    }
    $.getJSON('/json/play', initializeNewGameRound);
  }

  function enableEvenFancierGameLinksSoYouCanActuallyPlayNow($link) {
    var gameId = $link.data('game');
    var id = $link.data('id');
    $link.click(function(event) {
      event.preventDefault();

      var answer = {
        game: gameId,
        guess: id
      };

      // TODO: Spinner and deactivation etc

      $.post('/play', answer).done(handlePlayAPIAnswer);
    });
  }

  $('.game-link').each(function() {
    enableEvenFancierGameLinksSoYouCanActuallyPlayNow($(this));
  });
});
